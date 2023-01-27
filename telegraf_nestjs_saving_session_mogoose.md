[На главную](README.md)

## nestjs-telegraf mongo session middleware

Ключевые слова: nestjs, mongoose, telegraf, nestjs-telegraf

---

Было потрачено несколько часов на решение этого вопроса. Хочу поделиться реализацией. Изначально информация была взята из [Новогодняя история одного телеграм-бота](https://habr.com/ru/company/tinkoff/blog/596287/), но в статье отсутсвует подробное описание реализации необходимой функции. Ну что ж, приступим.

1. Создаем проект через nestjs-cli (подробности опустим)

2. Формируем схему модели, которая будет отвечать непосредственно за сохранение телеграм сессий в нашей базе данных (session.schema.ts):

```typescript
import { Prop, Schema, SchemaFactory } from "@nestjs/mongoose";
import { Document, Types } from "mongoose";
import { SceneContext } from "telegraf/typings/scenes";

export type TelegramSessionDocument = TelegramSession & Document;

@Schema()
export class TelegramSession {
  _id: Types.ObjectId;

  @Prop({ required: true })
  userId: number;

  @Prop({ type: Object })
  session: SceneContext["session"];

  createdAt: Date;
}

export const TelegramSessionSchema =
  SchemaFactory.createForClass(TelegramSession);
```

3. Далее создаем сервис, который будет записывать\изменять данные в базе (session.service.ts):

```typescript
import { Injectable, Logger } from "@nestjs/common";
import { InjectModel } from "@nestjs/mongoose";
import { Model } from "mongoose";
import { Middleware } from "telegraf";
import { SceneContext } from "telegraf/typings/scenes";
import { TelegramSession } from "./session.schema";

const EMPTY_SESSION = { __scenes: {} };

@Injectable()
export class SessionService {
  constructor(
    @InjectModel(TelegramSession.name)
    private readonly telegramSessionModel: Model<TelegramSession>
  ) {}

  async getSession(userId: number): Promise<SceneContext["session"]> {
    try {
      const user = await this.telegramSessionModel.findOne({ userId });
      if (user) {
        return user.session;
      } else {
        return EMPTY_SESSION;
      }
    } catch (e) {
      Logger.error(e);
    }
  }

  async saveSession(session: SceneContext["session"], userId: number) {
    try {
      const user = await this.telegramSessionModel.findOne({ userId });
      if (user) {
        user.session = session;
        await user.save();
      } else {
        const newUser = new this.telegramSessionModel({
          userId,
          session,
        });
        await newUser.save();
      }
    } catch (e) {
      Logger.error(e);
    }
  }

  createMongoDBSession(): Middleware<SceneContext> {
    return async (ctx, next) => {
      const id = ctx.chat.id;

      let session: SceneContext["session"] = EMPTY_SESSION;

      Object.defineProperty(ctx, "session", {
        get: function () {
          return session;
        },
        set: function (newValue) {
          session = Object.assign({}, newValue);
        },
      });

      session = (await this.getSession(id)) || EMPTY_SESSION;

      await next(); // wait all other middlewares
      await this.saveSession(session, id);
    };
  }
}
```

4. Создаем модуль для внедрения, только что созданной схемы и сервиса, в приложение(session.module.ts
   ):

```typescript
import { Module } from "@nestjs/common";
import { MongooseModule } from "@nestjs/mongoose";
import { TelegramSession, TelegramSessionSchema } from "./session.schema";
import { SessionService } from "./session.service";

@Module({
  imports: [
    MongooseModule.forFeature([
      { name: TelegramSession.name, schema: TelegramSessionSchema },
    ]),
  ],
  providers: [SessionService],
  exports: [SessionService],
})
export class SessionModule {}
```

5. Встраиваем созданный нами промежуточный обработчик в запуск телеграм бота(telegram.module.ts
   ):

```typescript
import { Module } from "@nestjs/common";
import { ConfigModule } from "@nestjs/config";
import { TelegrafModule } from "nestjs-telegraf";
import { SessionModule } from "../session/session.module";
import { SessionService } from "../session/session.service";
import { ChooseCryptoCurrencyScene } from "./scenes/choose-crypto.scene";
import { ChooseFiatCurrencyScene } from "./scenes/choose-fiat.scene";
import { TelegramService } from "./telegram.service";
import { TelegramUpdate } from "./telegram.update";

@Module({
  imports: [
    ConfigModule.forRoot(),
    TelegrafModule.forRootAsync({
      imports: [SessionModule],
      inject: [SessionService],
      useFactory: (sessionService: SessionService) => ({
        token: process.env.TG_TOKEN,
        middlewares: [sessionService.createMongoDBSession()],
      }),
    }),
  ],
  providers: [
    TelegramService,
    TelegramUpdate,
    ChooseFiatCurrencyScene,
    ChooseCryptoCurrencyScene,
  ],
})
export class TelegramModule {}
```

---

Следующий шаг - это взаимодействие с сессиями. Для удобства создадим несколько констант(telegram.constants.ts):

```typescript
export const SCENE_CHOOSE_FIAT_CURRENCY = "CHOOSE_FIAT_CURRENCY";
export const SCENE_CHOOSE_CRYPTO_CURRENCY = "CHOOSE_CRYPTO_CURRENCY";

export const ACTION_BUY = { text: "Купить крипту", callback: "buy" };
```

Добавим немного интерфейсов. Возможно telegraf и предоставляет необходимые типы, но я не нашел... Если знаешь как это сделать, поделись))) (telegram.interfaces.ts):

```typescript
import { Context } from "telegraf";
import { Update } from "telegraf/typings/core/types/typegram";
import { SceneContext } from "telegraf/typings/scenes";

interface SessionData {
  choosen_fiat_currency?: string;
  choosen_crypto_currency?: string;
}

export interface UserSessionContext extends Context {
  session?: SessionData;
}
export type MyContext = Context & UserSessionContext;

export type MySceneContext = UserSessionContext & SceneContext;

export type MySceneActionContext = MySceneContext & {
  update: Update.CallbackQueryUpdate;
};

export interface TelegrafMessage {
  text: string;
  message_id: number;
  date: number;
}

export interface TelegrafContactMessage extends TelegrafMessage {
  contact: {
    phone_number: string;
  };
}
```

Теперь формируем сценарий начала использования бота (telegram.update.ts):

```typescript
import { Logger } from "@nestjs/common";
import { Action, Ctx, Message, On, Start, Update } from "nestjs-telegraf";
import { Context, Markup } from "telegraf";
import { SceneContext } from "telegraf/typings/scenes";
import { ACTION_BUY, SCENE_CHOOSE_FIAT_CURRENCY } from "./telegram.constants";
import { MyContext } from "./telegram.interfaces";

@Update()
export class TelegramUpdate {
  @Start()
  async start(@Ctx() ctx: MyContext) {
    try {
      ctx.reply(
        "Выберите действие",
        Markup.inlineKeyboard([
          [{ text: ACTION_BUY.text, callback_data: ACTION_BUY.callback }],
        ])
      );
    } catch (e) {
      Logger.error(e);
    }
  }

  @Action(ACTION_BUY.callback)
  async startBuyScene(@Ctx() ctx: SceneContext) {
    try {
      await ctx.answerCbQuery();
      await ctx.scene.enter(SCENE_CHOOSE_FIAT_CURRENCY);
    } catch (e) {
      Logger.error(e);
    }
  }
}
```

Да начнется взаимодействие с сессиями (choose-fiate.scene.ts
):

```typescript
import { Action, Ctx, Scene, SceneEnter } from "nestjs-telegraf";
import {
  SCENE_CHOOSE_CRYPTO_CURRENCY,
  SCENE_CHOOSE_FIAT_CURRENCY,
} from "../telegram.constants";
import { MySceneActionContext, MySceneContext } from "../telegram.interfaces";

@Scene(SCENE_CHOOSE_FIAT_CURRENCY)
export class ChooseFiatCurrencyScene {
  @SceneEnter()
  async enter(@Ctx() ctx: MySceneContext) {
    ctx.editMessageText("Какой валютой будете покупать?", {
      reply_markup: {
        inline_keyboard: [
          [{ text: "Доллары", callback_data: "USD" }],
          [{ text: "Рубли", callback_data: "RUB" }],
        ],
      },
    });
  }

  @Action(/USD|RUB/)
  async onAnswer(@Ctx() ctx: MySceneActionContext) {
    const userAnswer = ctx.update.callback_query.data;

    // Это и была наша цель. После выполнения кода ниже, данные
    // сохраняться в базе и мы в любой момент времени сможем определить
    // что, как и где делал пользователь
    ctx.session.choosen_fiat_currency = userAnswer;

    await ctx.scene.enter(SCENE_CHOOSE_CRYPTO_CURRENCY);
  }
}
```

Ну а теперь мы получаем данные сессии, только уже в другой сцене (choose-crypto.scene.ts
):

```typescript
import { Action, Ctx, Scene, SceneEnter } from "nestjs-telegraf";
import { SCENE_CHOOSE_CRYPTO_CURRENCY } from "../telegram.constants";
import { MySceneActionContext, MySceneContext } from "../telegram.interfaces";

@Scene(SCENE_CHOOSE_CRYPTO_CURRENCY)
export class ChooseCryptoCurrencyScene {
  @SceneEnter()
  async enter(@Ctx() ctx: MySceneContext) {
    if (ctx.session.choosen_fiat_currency == "RUB") {
      await ctx.editMessageText("Доступные валюты и курс покупки:", {
        reply_markup: {
          inline_keyboard: [
            [{ text: "BTC  - 1340231 ₽", callback_data: "BTC" }],
            [{ text: "ETH  - 400244 ₽", callback_data: "ETH" }],
            [{ text: "USDT - 67 ₽", callback_data: "USDT" }],
          ],
        },
      });
    } else {
      await ctx.editMessageText("Доступные валюты и курс покупки:", {
        reply_markup: {
          inline_keyboard: [
            [{ text: "BTC  - 33001 $", callback_data: "BTC" }],
            [{ text: "ETH  - 2100 $", callback_data: "ETH" }],
            [{ text: "USDT - 1 $", callback_data: "USDT" }],
          ],
        },
      });
    }
  }

  @Action(/BTC|ETH|USDT/)
  async onAnswer(@Ctx() ctx: MySceneActionContext) {
    const userAnswer = ctx.update.callback_query.data;

    ctx.session.choosen_crypto_currency = userAnswer;

    const message =
      "Вот, держи данные сессии: " + JSON.stringify(ctx.session, null, 3);

    await ctx.editMessageText(message);

    await ctx.scene.leave();
  }
}
```
