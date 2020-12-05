#!/bin/zsh
# @author   yanglifeng
# @date     20201206
# @platform Apple M1 - macOS Big Sur 11.0.1 (20B29) 

set -o pipefail

NODEJS_VERSION_DEFAULT=v14.15.0
NODEJS_VERSION_LIST=(v6.10.0 v8.11.1 v10.16.0 v12.7.0 v14.15.0)
ZSH_PROFILE=~/.zsh_profile
ZSHRC=~/.zshrc

notFound() {
    type $1 | grep -c 'not found'
}

useZshProfile() {
    if [ $(fgrep -c "source $ZSH_PROFILE" $ZSHRC) -eq 0 ]
    then
        echo "source $ZSH_PROFILE" >> $ZSHRC
    fi
    source $ZSHRC
}

installGUISoftware() {
    brew install --cask $1
}

addConfig() {
    f=$ZSH_PROFILE
    touch $f
    if [ $(fgrep -c $1 $f) -eq 0 ]
    then 
        echo $1 >> $f
    fi
    source $f
}



initCLISoftware() {
    # xcode-select 第一次安装花的时间会比较久
    xcode-select --install

    # homebrew 暂时不支持arm64架构，得用Rosetta2的方式打开终端
    if [ $(notFound brew) -gt 0 ]
    then
        /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
    fi

    # 禁用brew update
    addConfig 'export HOMEBREW_NO_AUTO_UPDATE=true'

    # 指定lang
    addConfig 'export LANGUAGE=en_US.UTF-8'

    # 修改brew配置指向中科大源
    brew="$(brew --repo)"
    cd "$brew"
    git remote set-url origin https://mirrors.ustc.edu.cn/brew.git

    mkdir -p "$brew/Library/Taps/homebrew"
    cd "$brew/Library/Taps/homebrew"
    git clone https://mirrors.ustc.edu.cn/homebrew-core.git
    git clone https://mirrors.ustc.edu.cn/homebrew-cask.git
    cd ~
    brew update

    # git
    brew install git

    # zsh
    brew install zsh

    # oh-my-zsh
    sh -c "$(curl -fsSL https://raw.github.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"

    # nvm
    if [ $(notFound nvm) -gt 0 ]
    then
        brew install nvm
    fi

    addConfig 'export NVM_DIR="$HOME/.nvm"
    [ -s "/usr/local/opt/nvm/nvm.sh" ] && . "/usr/local/opt/nvm/nvm.sh"  # This loads nvm
    [ -s "/usr/local/opt/nvm/etc/bash_completion.d/nvm" ] && . "/usr/local/opt/nvm/etc/bash_completion.d/nvm"  # This loads nvm bash_completion'

    # nodejs
    for node_version in $NODEJS_VERSION_LIST
    do
        nvm install $node_version
    done
    nvm alias default $NODEJS_VERSION_DEFAULT

    # 修改npm配置指向公司源
    npm config set registry 'https://registry.npm.taobao.org/' # 三方包使用淘宝npm，更新比较及时
    npm config set '@youzan:registry' 'http://registry.npm.qima-inc.com/' # @youzan的二方包使用公司npm
    npm config set '@qima-inc:registry' 'http://registry.npm.qima-inc.com/' # @qima-inc的二方包使用公司ynpm
}

initGUISoftware() {
    # 企业微信 & 微信
    installGUISoftware wechatwork
    installGUISoftware wechat
    # chrome
    installGUISoftware google-chrome
    # vscode
    installGUISoftware visual-studio-code
    # iTerm2
    installGUISoftware iterm2
    # zanProxy 需要提供个cask的安装方式
    # installGUISoftware zanProxy
    # sketch 下载的是正版的，而且速度极慢
    # installGUISoftware sketch
    # easy-connect 暂无
}

main() {
    echo "准备前端开发环境，安装必备的软件"
    useZshProfile
    initCLISoftware
    initGUISoftware
    echo "已经完成了，快试试吧"
}

main