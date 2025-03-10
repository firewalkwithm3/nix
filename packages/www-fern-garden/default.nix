{
  lib,
  pkgs,
  stdenv,
  ...
}:

stdenv.mkDerivation {
  pname = "www-fern-garden";
  version = "1.0";

  src = ./.;

  css = pkgs.writeTextFile {
    name = "index.css";
    text = ''
      body {
      	background: #151515 url(images/ferns.webp) no-repeat center center fixed; /* image uploaded by @sebastians at pexels.com */
      	-webkit-background-size: cover;
      	-moz-background-size: cover;
      	-o-background-size: cover;
      	background-size: cover;
        color: #e8e3e3;
      }

      .center {
      	position: absolute;
      	top: 50%;
      	left: 50%;
      	transform: translate(-50%,-50%);
      	text-align: center;
      }

      .name {
        margin: 36px;
      }

      .name img {
        width: 264px;
        filter: invert(100%);
      }


      .socials-item img {
        margin: 12px;
        width: 36px;
        filter: invert(100%);
      }
    '';
  };

  html = pkgs.writeTextFile {
    name = "index.html";
    text = ''
      <!DOCTYPE HTML>
      <html>
      	<head>
      	  <title>Fern Garden</title>
      	  <meta charset="utf-8"/>
      	  <link rel="stylesheet" href="index.css">
      	  <link rel="icon" type="image/x-icon" href="images/favicon.png"/>
      	  <meta name="viewport" content="width=device-width, initial-scale=1">
      	</head>
      	<body>
      	  <div class="center">
          <div class="name"><img src="images/name.svg" alt="fern"></div>
      	    <div class="socials">
              <a class="socials-item" href="mailto:mail@fern.garden"><img src="images/socials/email.svg" alt="Email" /></a>
              <a class="socials-item" href="https://matrix.to/#/@fern:mx.fern.garden"><img src="images/socials/matrix.svg" alt="Matrix" /></a>
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
    description = "My personal homepage";
    license = licenses.mit;
    platforms = platforms.all;
  };
}
