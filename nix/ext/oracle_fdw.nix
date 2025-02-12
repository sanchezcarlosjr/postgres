{ lib, stdenv, fetchFromGitHub, curl, postgresql, oracle-instantclient, oci-cli }:

stdenv.mkDerivation rec {
  pname = "oracle_fdw";
  version = "ORACLE_FDW_2_7_0";

  allowUnfree = true;

  buildInputs = [ curl postgresql oracle-instantclient oci-cli ];

  src = fetchFromGitHub {
    owner = "laurenz";
    repo = pname;
    rev = "refs/tags/${version}";
    hash = "sha256-YNy7ZBDocLuYatgMpUwM0TH5UOebhOYpr+kmZG10vIA=";
  };

  env.NIX_CFLAGS_COMPILE = "-Wno-error";
  env.AWESOME_FLAG = "1";

  buildPhase = ''
     export LD_LIBRARY_PATH=${lib.makeLibraryPath [oracle-instantclient]}
     export ORACLE_HOME=${oracle-instantclient}
     make
  '';

  installPhase = ''
    echo "===Installing phase==="
    mkdir -p $out/{lib,share/postgresql/extension}

    cp *${postgresql.dlSuffix}      $out/lib
    echo ${postgresql.dlSuffix}


    cp sql/*.sql $out/share/postgresql/extension
    cp *.sql $out/share/postgresql/extension
    cp *.control $out/share/postgresql/extension
    exit 1

  '';

  meta = with lib; {
    description = "Async networking for Postgres";
    homepage = "https://github.com/supabase/pg_net";
    maintainers = with maintainers; [ samrose ];
    platforms = postgresql.meta.platforms;
    license = licenses.postgresql;
  };
}
