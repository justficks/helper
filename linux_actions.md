### Расширить диск диск на максимум (фактически диск 1Тб, но система показывает 100Гб):

```bash
sudo lvextend -l +100%FREE /dev/ubuntu-vg/ubuntu-lv
```

```bash
sudo resize2fs /dev/ubuntu-vg/ubuntu-lv
```
