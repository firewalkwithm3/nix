{
  lib,
  pkgs,
  stdenv,
  ...
}:

stdenv.mkDerivation {
  pname = "www-transgender-pet";
  version = "1.0";

  src = ./.;

  css = pkgs.writeTextFile {
    name = "index.css";
    text = ''
          body {
      	background: #151515;
        color: #e8e3e3;
      }

      .center {
      	position: absolute;
      	top: 50%;
      	left: 50%;
      	transform: translate(-50%,-50%);
      	text-align: center;
      }

      .cat img {
        width: 256px;
        margin: 12px;
      }

    '';
  };

  html = pkgs.writeTextFile {
    name = "index.html";
    text = ''
          <!DOCTYPE HTML>
          <html>
            <head>
              <title>meow!!</title>
      	<meta charset="utf-8"/>
      	<link rel="stylesheet" href="index.css">
      	<link rel="icon" type="image/x-icon" href="images/favicon.png"/>
      	<meta name="viewport" content="width=device-width, initial-scale=1">
            </head>

            <body>
              <div class="center">
              <div class="cat">
                <img src="images/cat.png" alt="Pixel art of an orange cat next to a transgender flag." />
              </div>
             </div>
            </body>
          </html>
    '';
  };

  installPhase = ''
    mkdir -p $out/var/www

    cp -r $src/images $out/var/www/
    cp $html $out/var/www/index.html
    cp $css $out/var/www/index.css
  '';

  meta = with lib; {
    description = "A website for trans cats";
    license = licenses.mit;
    platforms = platforms.all;
  };
}
