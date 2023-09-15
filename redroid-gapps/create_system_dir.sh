decompress_files() {
    local directory="$1"
    for file in "$directory"/*.tar.lz; do
        # Проверка на существование файлов .tar.lz перед декомпрессией
        if [[ -f "$file" ]]; then
            lzip -d "$file" # декомпрессия
            tar -xf "${file%.lz}" -C "$directory" # извлечение содержимого
            rm "${file%.lz}" # удаление .tar файла после извлечения
        fi
    done
}

move_contents() {
    # Параметры функции
    local dist_dir="$1/$3"   # Куда складываем
    local source_dir="$2"    # Где искать
    local search_dir="$3"    # Что искать

    mkdir -p $dist_dir

    # Рекурсивный поиск нужной директории
    find "$source_dir" -type d -name "$search_dir" | while read matched_dir; do
        # Перемещение содержимого найденной директории в целевую директорию
        rsync -av "$matched_dir/" "$dist_dir/" > /dev/null
    done
}


SYSTEM_DIR=$(pwd)/system
ARCHIVE_DIR=$(pwd)/archive

rm -r $SYSTEM_DIR $ARCHIVE_DIR
mkdir -p $SYSTEM_DIR $ARCHIVE_DIR

unzip "$1" -d $ARCHIVE_DIR > /dev/null
decompress_files "$ARCHIVE_DIR/GApps"
decompress_files "$ARCHIVE_DIR/Core"

move_contents $SYSTEM_DIR $ARCHIVE_DIR "priv-app" 
move_contents $SYSTEM_DIR $ARCHIVE_DIR "app" 
move_contents $SYSTEM_DIR $ARCHIVE_DIR "etc" 
move_contents $SYSTEM_DIR $ARCHIVE_DIR "framework" 
move_contents $SYSTEM_DIR $ARCHIVE_DIR "product" 