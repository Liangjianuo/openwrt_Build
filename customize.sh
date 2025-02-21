#!/bin/bash
set -eo pipefail

# 配置路径检测
CONFIG_GEN="package/base-files/files/bin/config_generate"
[ -f "$CONFIG_GEN" ] || { echo "错误：找不到$CONFIG_GEN"; exit 1; }

# 安全修改IP和主机名
sed -i -e 's/192\.168\.1\.1/192.168.1.251/g' \
       -e 's/OpenWrt/kenzo/g' "$CONFIG_GEN"

# 主题管理（带容错）
THEME_REPO="https://github.com/kenzok8/luci-theme-ifit.git"
if git ls-remote --exit-code "$THEME_REPO" &>/dev/null; then
    git clone --depth 1 --branch main "$THEME_REPO" package/lean/luci-theme-ifit
    echo "CONFIG_PACKAGE_luci-theme-ifit=y" >> .config
else
    sed -i 's/luci-theme-bootstrap/luci-theme-argon/g' feeds/luci/collections/luci/Makefile
fi

# 禁用危险操作
# 注释掉以下高风险配置：
# sed -i 's?zstd$?zstd ucl upx...g' tools/Makefile
# sed -i 's/$(TARGET_DIR)) install...g' package/Makefile
# sed -i 's/root:.*/root:.../g' package/base-files/files/etc/shadow

# 添加安全基线
echo "CONFIG_PASSWORD_WARN=y" >> .config  # 密码过期提醒
echo "CONFIG_FORCE_PASSWORD_CHANGE=y" >> .config
