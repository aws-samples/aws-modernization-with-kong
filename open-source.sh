#This script will remove the bundled Learn theme and add a git submodule for the open source Hugo learn theme.

rm -r workshop/themes/learn/
echo "Removed local Hugo Learn theme from /workshop/themes/learn."

cd workshop/themes
git submodule add https://github.com/matcornic/hugo-theme-learn
echo "Hugo Learn theme added as a git submodule at /workshop/themes/hugo-theme-learn."
cd ../../

#update workshop/config.toml to use hugo-theme-learn
sed -i '' 's/^theme.*/theme = \"hugo-theme-learn\"/' workshop/config.toml
echo "Updated ./config.toml to use hugo-theme-learn."