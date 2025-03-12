{
  fetchFromGitHub,
  buildDotnetModule,
  dotnetCorePackages,
}:

buildDotnetModule rec {
  pname = "webone";
  version = "0.17.4";

  src = fetchFromGitHub {
    owner = "atauenis";
    repo = pname;
    rev = "v${version}";
    sha256 = "sha256-pSHn/TyiRyUSlylo7fY1wXan6TLtLyk1GR5UZQl3/C4=";
  };

  projectFile = "WebOne.csproj";
  nugetDeps = ./deps.json;
  dotnet-sdk = dotnetCorePackages.sdk_6_0_1xx;

  meta = {
    homepage = "https://github.com/atauenis/webone";
    description = "HTTP 1.x proxy that makes old web browsers usable again in the Web 2.0 world.";
  };
}
