#This script will remove the bundled Learn theme and add a git submodule for the open source Hugo learn theme.

rm -r workshop/themes/learn/
echo "Removed local Hugo Learn theme from /workshop/themes/learn."

cd workshop/themes
git submodule add https://github.com/matcornic/hugo-theme-learn
echo "Hugo Learn theme added as a git submodule at /workshop/themes/hugo-theme-learn."
cd ../../

#update workshop/config.toml to use hugo-theme-learn
sed -i '' 's/^theme.*/theme = \"hugo-theme-learn\"/' workshop/config.toml
echo "Updated config.toml to use hugo-theme-learn."

#remove known AWS logos from the codebase
if [ -e workshop/static/images/aws-open-source.jpg ]; then
    rm workshop/static/images/aws-open-source.jpg
    echo "Removed workshop/static/images/aws-open-source.jpg."
fi

if [ -e workshop/static/images/apn-logo.jpg ]; then
    rm workshop/static/images/apn-logo.jpg
    echo "Removed workshop/static/images/apn-logo.jpg."
fi

if [ -e workshop/content/shortcodes/attachments/_index.en.files/AWS_AWS_logo_RGB.png ]; then
    rm workshop/content/shortcodes/attachments/_index.en.files/AWS_AWS_logo_RGB.png
    echo "Removed workshop/content/shortcodes/attachments/_index.en.files/AWS_AWS_logo_RGB.png."
fi


