FROM debian:bookworm-slim
ENV TZ=America/Chicago
RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone
RUN apt-get update && \
    apt-get dist-upgrade -y && \
	apt-get install -y vim curl git apt-transport-https bash zsh zip unzip sqlite3 wget gnupg2 locales
RUN wget -O /etc/apt/trusted.gpg.d/php.gpg https://packages.sury.org/php/apt.gpg && \
    echo "deb https://packages.sury.org/php/ bookworm main" > /etc/apt/sources.list.d/php.list && \
    curl https://packages.microsoft.com/keys/microsoft.asc | tee /etc/apt/trusted.gpg.d/microsoft.asc && \
    curl https://packages.microsoft.com/config/debian/12/prod.list | tee /etc/apt/sources.list.d/mssql-release.list && \
	sed -i 's/ signed-by=\/usr\/share\/keyrings\/microsoft-prod.gpg//' /etc/apt/sources.list.d/mssql-release.list && \
	cat /etc/apt/sources.list.d/mssql-release.list && \
	apt-get update && \
	ACCEPT_EULA=Y apt-get install php8.2 php8.2-dev php8.2-xml php8.2-curl php8.2-smbclient php8.2-gd php8.2-mbstring php8.2-zip php8.2-ssh2 php8.2-sqlite3 php8.2-imap php8.2-mysqli msodbcsql18 mssql-tools18 -y --allow-unauthenticated && \
	echo 'export PATH="$PATH:/opt/mssql-tools18/bin"' >> ~/.bash_profile && \
	echo 'export PATH="$PATH:/opt/mssql-tools18/bin"' >> ~/.bashrc && \
	apt-get install unixodbc-dev -y
RUN sed -i 's/# en_US.UTF-8 UTF-8/en_US.UTF-8 UTF-8/g' /etc/locale.gen && \
    locale-gen
RUN curl https://getcomposer.org/download/latest-stable/composer.phar > /tmp/composer.phar && \
    mv /tmp/composer.phar /usr/local/bin/composer && \
    chmod +x /usr/local/bin/composer
RUN pecl install sqlsrv && \
    pecl install pdo_sqlsrv && \
	printf "; priority=20\nextension=sqlsrv.so\n" > /etc/php/8.2/mods-available/sqlsrv.ini && \
	printf "; priority=30\nextension=pdo_sqlsrv.so\n" > /etc/php/8.2/mods-available/pdo_sqlsrv.ini && \
	phpenmod -v 8.2 sqlsrv pdo_sqlsrv
COPY openssl.cnf /etc/ssl/openssl.cnf

CMD ["bash"]
WORKDIR /app
