
resource "google_compute_instance" "bitbucket_server" {
  name         = "bitbucket-server"
  machine_type = var.machine_type
  zone         = var.zone

  boot_disk {
    initialize_params {
      image = "debian-cloud/debian-10"
    }
  }

  network_interface {
    network = "default"

    access_config {
      // Ephemeral IP
    }
  }

  metadata = {
    // Install Git, Java 8, and PostgreSQL
    startup-script = <<-EOF
      #!/bin/bash
      sudo apt-get update -y
      sudo apt-get wget -y
      sudo apt-get install -y git
      sudo apt-get install -y openjdk-8-jdk
      sudo apt-get install -y postgresql-11 postgresql-contrib

      # Create Bitbucket database and user
      sudo -u postgres psql -c "CREATE USER bitbucket WITH PASSWORD 'mysecretpassword';"
      sudo -u postgres createdb bitbucket -O bitbucket

      # Download and install Bitbucket Server
      mkdir /opt/atlassian
      cd /opt/atlassian
      wget https://www.atlassian.com/software/stash/downloads/binary/atlassian-bitbucket-7.8.0-x64.bin
      chmod a+x atlassian-bitbucket-7.8.0-x64.bin
      ./atlassian-bitbucket-7.8.0-x64.bin -q -varfile response.varfile

      # Configure Bitbucket Server
      /opt/atlassian/bitbucket/bin/start-bitbucket.sh
    EOF
  }

  tags = ["bitbucket-server"]
}

output "public_ip" {
  value = google_compute_instance.bitbucket_server.network_interface.0.access_config.0.nat_ip
}

