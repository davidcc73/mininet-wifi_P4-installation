libboost(){
    wget http://repo.pureos.net/pureos/pool/main/b/boost1.62/libboost-system1.62.0_1.62.0+dfsg-10+b1_amd64.deb
    sudo apt install -y ./libboost-system1.62.0_1.62.0+dfsg-10+b1_amd64.deb

    wget http://repo.pureos.net/pureos/pool/main/b/boost1.62/libboost-thread1.62.0_1.62.0+dfsg-10+b1_amd64.deb
    sudo apt install -y ./libboost-thread1.62.0_1.62.0+dfsg-10+b1_amd64.deb

    wget http://repo.pureos.net/pureos/pool/main/b/boost1.62/libboost-filesystem1.62.0_1.62.0+dfsg-10+b1_amd64.deb
    sudo apt install -y ./libboost-filesystem1.62.0_1.62.0+dfsg-10+b1_amd64.deb

    wget http://repo.pureos.net/pureos/pool/main/b/boost1.62/libboost-program-options1.62.0_1.62.0+dfsg-10+b1_amd64.deb
    sudo apt install -y ./libboost-program-options1.62.0_1.62.0+dfsg-10+b1_amd64.deb

}

dependencies(){
    echo "Installing Dependencies"

    #echo "deb http://deb.debian.org/debian bookworm-backports main" | sudo tee /etc/apt/sources.list.d/bookworm-backports.list
    sudo apt update


    ############## libgrpc++1   (Since its also a PI and P4c dependence)
    wget http://ftp.es.debian.org/debian/pool/main/a/abseil/libabsl20200923_0~20200923.3-2_amd64.deb
    sudo apt -y install ./libabsl20200923_0~20200923.3-2_amd64.deb

    wget http://security.debian.org/debian-security/pool/updates/main/o/openssl/libssl1.1_1.1.1w-0+deb11u2_amd64.deb
    sudo apt -y install ./libssl1.1_1.1.1w-0+deb11u2_amd64.deb

    wget http://ftp.es.debian.org/debian/pool/main/g/grpc/libgrpc10_1.30.2-3_amd64.deb
    sudo apt -y install ./libgrpc10_1.30.2-3_amd64.deb
    
    ### libprotobuf23
    wget http://ftp.es.debian.org/debian/pool/main/p/protobuf/libprotobuf23_3.12.4-1+deb11u1_amd64.deb    #Its for debian 11 but it works for debian 12
    sudo apt -y install ./libprotobuf23_3.12.4-1+deb11u1_amd64.deb 

    wget http://ftp.de.debian.org/debian/pool/main/g/grpc/libgrpc++1_1.30.2-3_amd64.deb
    sudo apt -y install ./libgrpc++1_1.30.2-3_amd64.deb

    wget http://repo.pureos.net/pureos/pool/main/g/grpc/libgrpc-dev_1.30.2-3_amd64.deb
    sudo apt -y install ./libgrpc-dev_1.30.2-3_amd64.deb

    wget http://repo.pureos.net/pureos/pool/main/g/grpc/libgrpc++-dev_1.30.2-3_amd64.deb
    sudo apt -y install ./libgrpc++-dev_1.30.2-3_amd64.deb

    ###libprotoc23
    wget http://repo.pureos.net/pureos/pool/main/p/protobuf/libprotoc23_3.12.4-1+deb11u1_amd64.deb
    sudo apt -y install ./libprotoc23_3.12.4-1+deb11u1_amd64.deb

    ### protobuf-compiler
    wget http://repo.pureos.net/pureos/pool/main/p/protobuf/protobuf-compiler_3.12.4-1+deb11u1_amd64.deb
    sudo apt -y install ./protobuf-compiler_3.12.4-1+deb11u1_amd64.deb
    
    wget http://repo.pureos.net/pureos/pool/main/g/grpc/protobuf-compiler-grpc_1.30.2-3_amd64.deb
    sudo apt install -y ./protobuf-compiler-grpc_1.30.2-3_amd64.deb

}

install_bmv2_stratum(){   #a single package for bmv2 and stratum
    git clone https://github.com/p4lang/behavioral-model.git || echo "Repository already cloned."
    cd behavioral-model
    ./install_deps.sh
    cd ..

    ### libboost packages
    libboost


    wget https://github.com/stratum/stratum/releases/download/2022-06-30/stratum-bmv2-22.06-amd64.deb
    sudo apt install -y ./stratum-bmv2-22.06-amd64.deb

    git clone https://github.com/stratum/stratum || echo "Repository already cloned."
    export PYTHONPATH=/stratum/tools/mininet:$PYTHONPATH                    #Sometimes needs to be ran mannually after the installation
}

install_PI(){
    #upgrade to the version PI needs
    sudo apt-get update
    sudo apt-get install -y libgrpc-dev libgrpc++-dev libprotobuf-dev
    


    git clone https://github.com/p4lang/PI || echo "Repository already cloned."
    cd PI
    git submodule update --init --recursive

    ./autogen.sh
    ./configure --with-proto
    make
    make check
    make install

    sudo ldconfig
    cd ..
}

install_p4c(){        
    ############## libssl1.1_1.1
    wget http://repo.pureos.net/pureos/pool/main/o/openssl/libssl1.1_1.1.1n-0+deb10u3_amd64.deb
    sudo apt install -y --allow-downgrades ./libssl1.1_1.1.1n-0+deb10u3_amd64.deb

    ############## libthrift
    wget http://repo.pureos.net/pureos/pool/main/t/thrift/libthrift-0.13.0_0.13.0-6_amd64.deb
    sudo apt install -y ./libthrift-0.13.0_0.13.0-6_amd64.deb


    # Debian 11 (Bullseye) package
    echo 'deb https://download.opensuse.org/repositories/home:/p4lang/Debian_11/ /' | sudo tee /etc/apt/sources.list.d/home:p4lang.list
    curl -fsSL https://download.opensuse.org/repositories/home:p4lang/Debian_11/Release.key | gpg --dearmor | sudo tee /etc/apt/trusted.gpg.d/home_p4lang.gpg > /dev/null
    sudo apt update
    sudo apt install p4lang-p4c
}


set -e  # Stop the script on any error
echo "127.0.0.1 mininet-wifi" >> /etc/hosts             #To enable the usage of sudo
echo "Starting setup"

install_bmv2_stratum

dependencies
install_PI
#install_p4c

sudo service openvswitch-switch start               #enable openvswitch
sudo apt install iputils-ping                       #install ping

echo "Setup complete"