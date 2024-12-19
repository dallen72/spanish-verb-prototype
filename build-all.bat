copy /Y src\index.css dist\index.css && copy /Y src\index.html dist\index.html && node_modules\.bin\esbuild src\main.js --bundle --outfile=dist\module-build.js

