{
  lib,
  buildGoModule,
  fetchFromGitHub,
  nix-update-script,
}:

buildGoModule rec {
  pname = "google-cloud-sql-proxy";
  version = "2.16.0";

  src = fetchFromGitHub {
    owner = "GoogleCloudPlatform";
    repo = "cloud-sql-proxy";
    rev = "v${version}";
    hash = "sha256-XrcJnPJ00WaHZoAqUs9q4mW8Aj2NUnKAzBmDnWOLTwY=";
  };

  subPackages = [ "." ];

  vendorHash = "sha256-LDl19a+YN+dgdw+en/CGW6e7tQNTAhIrjem0Ajq3OZE=";

  checkFlags = [
    "-short"
  ];

  passthru.updateScript = nix-update-script { };

  meta = with lib; {
    description = "Utility for ensuring secure connections to Google Cloud SQL instances";
    longDescription = ''
      The Cloud SQL Auth Proxy is a utility for ensuring secure connections to your Cloud SQL instances.
      It provides IAM authorization, allowing you to control who can connect to your instance through IAM permissions,
      and TLS 1.3 encryption, without having to manage certificates.
      See the [Connecting Overview](https://cloud.google.com/sql/docs/mysql/connect-overview) page for more information
      on connecting to a Cloud SQL instance, or the [About the Proxy](https://cloud.google.com/sql/docs/mysql/sql-proxy)
      page for details on how the Cloud SQL Proxy works.
    '';
    homepage = "https://github.com/GoogleCloudPlatform/cloud-sql-proxy";
    license = licenses.asl20;
    maintainers = with maintainers; [
      nicknovitski
      totoroot
    ];
    mainProgram = "cloud-sql-proxy";
  };
}
