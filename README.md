# dotfiles

macOSの環境構築用スクリプトを管理するリポジトリです。macOSの設定を適用し、Git・SSH・Zshの設定ファイルを配置して、Homebrewのパッケージをインストールします。

実行スクリプトとmacOSの設定値はこのリポジトリで管理し、Homebrewのパッケージ一覧とGit・SSH・Zshの設定は別のプライベートリポジトリで管理します。

## ディレクトリ構成

```text
.
├── install.sh              # 環境構築のエントリーポイント
├── .bin/
│   ├── config-path.sh      # プライベート設定ディレクトリの解決
│   ├── defaults.sh         # macOSの設定値の検証・適用
│   ├── config.sh           # 設定ファイルの検証・リンク作成
│   └── brew.sh             # パッケージ一覧の検証・インストール
└── config/
    └── defaults.json       # macOSの設定値
```

## 事前準備

対象はmacOSのApple Silicon（`arm64`）およびIntel（`x86_64`）です。Gitでリポジトリを取得できる環境と、依存関係のダウンロードに必要なネットワーク接続を用意してください。システム設定の適用には`sudo`を使用します。

プライベート設定リポジトリを、あらかじめ`~/git/dotfiles-config`にクローンしてください。別の場所を使用する場合は`DOTFILES_CONFIG_REPO_DIR`を指定します。スクリプトはプライベート設定リポジトリのクローンや更新を行いません。

プライベート設定リポジトリには、設定名ごとに以下のファイルを配置します。

```text
dotfiles-config/
└── personal/               # 設定名の例
    └── config/
        ├── Homebrew/
        │   ├── brew.txt    # Formulaを1行に1つ記載
        │   └── cask.txt    # Caskを1行に1つ記載
        ├── git/
        │   ├── .gitconfig
        │   └── .gitignore_global
        ├── ssh/
        │   └── config
        └── zsh/
            ├── .zprofile
            └── .zshrc
```

パッケージ一覧は`xargs`で`brew install`に渡すため、パッケージ名のみを記載してください。

## インストール

### 公開スクリプトを使用する

プライベート設定リポジトリを準備した後、公開されている`install.sh`を取得して実行できます。このリポジトリを事前にクローンする必要はありません。

```sh
export DOTFILES_PROFILE_NAME=personal
# 実行ファイルリポジトリのデフォルトの配置先は ~/git/dotfiles
# 実行ファイルリポジトリの配置先を変更する場合
# export DOTFILES_REPO_DIR=/path/to/dotfiles
# プライベート設定リポジトリの配置先を変更する場合
# export DOTFILES_CONFIG_REPO_DIR="/path/to/dotfiles-config"

/bin/bash -c "$(curl -fsSL https://go.saveourservers.io/dotfiles-macos)"
```

### ローカルのスクリプトを使用する

このリポジトリのルートで実行します。以下は`personal`という設定を使用する例です。

```sh
export DOTFILES_REPO_DIR="$PWD"
export DOTFILES_CONFIG_REPO_DIR="$HOME/git/dotfiles-config"
export DOTFILES_PROFILE_NAME=personal

/bin/bash install.sh
```

`install.sh`は、次の順序で処理します。

1. `DOTFILES_REPO_DIR`にこのリポジトリをクローンします。すでにGitリポジトリがある場合は`git pull --ff-only origin`で更新します。
2. 使用するプライベート設定ディレクトリを決定します。
3. Homebrewのパッケージ一覧、macOSの設定定義、配置する設定ファイルを`--check`で検証します。
4. Xcode Command Line Toolsが見つからない場合は、`xcode-select --install`を実行します。
5. macOSの設定を適用し、設定ファイルのシンボリックリンクを作成します。
6. Homebrewの公式インストールスクリプトを実行し、FormulaとCaskをインストールします。Caskには`--force`を指定します。

実行するとシステム設定、ホームディレクトリ内のファイル、インストール済みアプリケーションが変更されます。環境構築の対象として意図したmacOSアカウントで実行してください。リポジトリの更新も行うため、ローカルの変更を確認してから実行してください。

### 環境変数と設定の選択

| 変数 | 用途 | 既定値 |
| --- | --- | --- |
| `DOTFILES_REPO_DIR` | このリポジトリの配置先 | `~/git/dotfiles` |
| `DOTFILES_CONFIG_REPO_DIR` | プライベート設定リポジトリの配置先 | `~/git/dotfiles-config` |
| `DOTFILES_PROFILE_NAME` | `DOTFILES_CONFIG_REPO_DIR`直下の設定名 | 未指定時は候補から選択 |
| `DOTFILES_CONFIG_DEFINITIONS_DIR` | 設定ディレクトリの直接指定 | `$DOTFILES_CONFIG_REPO_DIR/$DOTFILES_PROFILE_NAME/config` |
| `DOTFILES_DEFAULTS_DEFINITION_FILE` | macOSの設定定義ファイル | `$DOTFILES_REPO_DIR/config/defaults.json` |

空でない`DOTFILES_CONFIG_DEFINITIONS_DIR`を指定した場合は、それを優先し、ディレクトリの存在を確認します。この場合、プライベート設定リポジトリの`.git`の確認と設定名の選択は省略します。

それ以外の場合、`DOTFILES_CONFIG_REPO_DIR`には`.git`ディレクトリが必要です。`DOTFILES_PROFILE_NAME`には、その直下のディレクトリ名を指定してください。未指定時は`*/config`に一致するディレクトリを探し、候補が1つなら自動選択、複数なら対話形式で選択します。候補が複数ある非対話実行では、`DOTFILES_PROFILE_NAME`の指定が必要です。

## 変更を適用せずに検証する

以下はこのリポジトリのルートで実行してください。設定名やパスは使用する環境に合わせて変更します。

```sh
export DOTFILES_REPO_DIR="$PWD"
export DOTFILES_CONFIG_REPO_DIR="$HOME/git/dotfiles-config"
export DOTFILES_PROFILE_NAME=personal

/bin/bash .bin/brew.sh --check
/bin/bash .bin/config.sh --check
/bin/bash .bin/defaults.sh --check
```

`brew.sh --check`はパッケージ一覧ファイルの読み取り可否とCPUアーキテクチャ、`config.sh --check`は配置元ファイルの読み取り可否を確認します。パッケージ名の存在や設定ファイルの内容までは検証しません。`defaults.sh --check`はJSONの読み取りと対応する値型などを確認し、設定を書き込みません。

## macOSの設定

設定値は[`config/defaults.json`](config/defaults.json)で管理します。macOS標準の`plutil`で読み取るため、JSONを解析するための追加パッケージは不要です。

| 項目 | 内容 |
| --- | --- |
| `userDefaults` | ユーザーの設定。`defaults write`で適用 |
| `systemDefaults` | システムの設定。`sudo defaults write`で適用 |
| `keyboardMappings` | キーボードごとの修飾キーの割り当て |
| `directories` | 作成するディレクトリ |

`userDefaults`と`systemDefaults`の各定義には`domain`、`key`、`type`、`value`を指定します。対応する型は`bool`、`int`、`float`、`string`、`array`です。文字列型の値と作成先ディレクトリの先頭にある`${HOME}/`は、実行ユーザーのホームディレクトリに展開されます。

現在の定義には、ダークモード、英語・日本語の言語設定、Dockの自動非表示、Finderの隠しファイル表示、スクリーンショットのPNG保存と保存先変更、キーボード設定などが含まれます。適用後にDockとFinderを再起動します。キーボードの割り当ては`-array-add`で追加するため、再実行時にも追加処理が行われます。

設定のみを適用する場合は、次のコマンドを使用します。

```sh
DOTFILES_REPO_DIR="$PWD" /bin/bash .bin/defaults.sh
```

## 設定ファイルの配置

`.bin/config.sh`は、プライベート設定ディレクトリのファイルから以下のシンボリックリンクを作成します。

| 配置元（`DOTFILES_CONFIG_DEFINITIONS_DIR`からの相対パス） | 配置先 |
| --- | --- |
| `git/.gitconfig` | `~/.gitconfig` |
| `git/.gitignore_global` | `~/.gitignore_global` |
| `ssh/config` | `~/.ssh/config` |
| `zsh/.zprofile` | `~/.zprofile` |
| `zsh/.zshrc` | `~/.zshrc` |

配置先が通常のファイルの場合は`~/.dotbackup/`にコピーしてから置き換えます。既存のシンボリックリンクは解除して作り直します。バックアップは同じファイル名で保存するため、過去のバックアップを上書きする場合があります。

`~/.ssh`の権限は`700`、リンク先のSSH設定ファイルの権限は`644`に設定します。リンク元を移動・削除すると設定を参照できなくなるため、プライベート設定ディレクトリは配置後も維持してください。

## 開発時の確認

ビルド工程や自動テストスイートはありません。シェルスクリプトを変更した場合は、構文確認と、利用可能ならShellCheckを実行します。

```sh
bash -n install.sh .bin/*.sh
shellcheck install.sh .bin/*.sh  # ShellCheckがインストールされている場合
git diff --check
```

設定定義の変更時は、対応するスクリプトの`--check`も実行してください。CPUアーキテクチャやHomebrewのパスに関わる変更は、Apple SiliconとIntelの両方で確認してください。
