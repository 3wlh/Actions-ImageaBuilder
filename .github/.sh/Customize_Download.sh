#!/bin/bash
function R6S() {
echo "R6S"
}
function OECT() {
[[ -d $(pwd)/files/www/cgi-bin ]] || mkdir -p "$(pwd)/files/www/cgi-bin"
# 下载文件
echo "OECT"
sub_cgi="https://github.com/3wlh/Actions-Build_Source/releases/download/sub.cgi/sub.cgi-aarch64_generic"
curl -# -L --fail "${sub_cgi}" -o "$(pwd)/files/www/cgi-bin/sub.cgi" && chmod 755 "$(pwd)/files/www/cgi-bin/sub.cgi"
page_cgi="https://github.com/3wlh/Actions-Build_Source/releases/download/page.cgi/page.cgi-aarch64_generic"
curl -# -L --fail "${page_cgi}" -o "$(pwd)/files/www/cgi-bin/page.cgi" && chmod 755 "$(pwd)/files/www/cgi-bin/page.cgi"
}
function 5Plus() {
echo "5Plus"
}
function x86-64() {
echo "x86-64"
}
echo "下载${Model}配置" && ${Model} && echo "下载${Model}配置......OK"