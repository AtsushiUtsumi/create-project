#!/bin/bash

GIT_DIRECTORY_NAME="xxx"
PROJECT_NAME="sugumi"
APPS_DIRECTORY_NAME="apps"
APP_NAMES=("${PROJECT_NAME}" "hoge" "fuga")


# エラー時に即終了
set -e

# 1. GITディレクトリを作成

if [ -d $GIT_DIRECTORY_NAME ];then
rm -r ${GIT_DIRECTORY_NAME}
fi

mkdir -p ${GIT_DIRECTORY_NAME}

# プロジェクトディレクトリに移動
cd ${GIT_DIRECTORY_NAME}

echo "services:" > docker-compose.yml
echo "db:container_name:image:ports:- 7777:7777environments:" >> docker-compose.yml
echo "rabbitmq-dev:container_name:image:rabbitmq:3.8-managementports:- 15672:15672environments:" >> docker-compose.yml
echo ":container_name:image:ports:environments:" >> docker-compose.yml

# リポジトリ全体で必要なディレクトリ、コンテナ用のディレクトリを作成
mkdir mysql
mkdir nginx
mkdir documents
echo -e "#!/bin/bash\necho RUN">> "run.sh"
chmod 777 ./run.sh
echo -e "#!/bin/bash\necho TEST">> "test.sh"
chmod 777 ./test.sh
echo >> README.md "# ${PROJECT_NAME}"
echo -e '### 開発ドキュメント\n- @documents' >> CLAUDE.md
mkdir ${APPS_DIRECTORY_NAME}
cd ${APPS_DIRECTORY_NAME}
echo "__pycache__/" >> .gitignore
echo "*.pyc" >> .gitignore
echo ".DS_Store" >> .gitignore
echo ".venv/" >> .gitignore
echo "db.sqlite3" >> .gitignore
echo ".env" >> .gitignore

# 2. 仮想環境の作成
echo "Django" >> requirements.txt
echo "openpyxl" >> requirements.txt
echo "pytest" >> requirements.txt

python3 -m venv .venv
source .venv/bin/activate
# 3. 必要なパッケージのインストール
pip install --upgrade pip
pip install -r requirements.txt

# 4. Django プロジェクトの作成
django-admin startproject ${PROJECT_NAME} .

# gitルートに戻って来る
cd ..

# 追加で作成したい
mkdir ci-template

# VSCodeで開く
#code .

# ここまで
exit






# これより下はアプリケーションを作成するようになってからでOK







# 5. アプリケーション ディレクトリの作成とアプリの生成
mkdir -p ${APPS_DIRECTORY_NAME}
cd ${APPS_DIRECTORY_NAME}

# アプリの作成
for APP_NAME in "${APP_NAMES[@]}"; do
echo "Creating app: ${APP_NAME}"
django-admin startapp ${APP_NAME}
done

cd ..

# 6. アプリディレクトリをPythonパッケージとして扱えるように
touch apps/__init__.py

# 7. settings.py にアプリの登録を追加
SETTINGS_FILE="${PROJECT_NAME}/settings.py"

add_to_installed_apps() {
  local app_name=$1
  if ! grep -q "'apps.${app_name}'" "$SETTINGS_FILE"; then
    sed -i "/INSTALLED_APPS = \[/a\    'apps.${app_name}'," "$SETTINGS_FILE"
  fi
}

for APP_NAME in "${APP_NAMES[@]}"; do
  add_to_installed_apps "${APP_NAME}"
done

echo "✅ Django プロジェクトとアプリの作成が完了しました。"
ls
code .
