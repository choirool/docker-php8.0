# docker-php8.0

contoh .gitlab-ci.yml

```.yml
image: choirool/chophp-8.0

stages:
  - preparation
  - security-checker
  - test
  - deploy

before_script:
  - mkdir -p ~/.ssh
  - echo -e "$SSH_PRIVATE_KEY" > ~/.ssh/id_rsa
  - chmod 600 ~/.ssh/id_rsa
  - echo -e "Host *\n\tStrictHostKeyChecking no\n\n" > ~/.ssh/config

linting:
  stage: preparation
  script:
    - pwd
    - find . -name \*.php -type f -exec php -l {} \; | if grep -v "No syntax errors detected"; then exit 1; fi
    - find . -name '*.sql' -o -name '*.db'
    - if [ $(find . -name '*.sql' -o -name '*.db' | wc -l) -gt 0 ]; then echo "ada ada database yang ikut"; exit 1 ; fi
    - if [ ! -f .env.example ]; then echo "file .env.example belum dibuat!"; exit 1; fi
    - CHECKDUPLICATEVARIABLE=$(cat .env.example | cut -d '=' -f1 | grep -v '^[[:space:]]*$' |  sort -n | uniq -c -d); if [ $(printf "$CHECKDUPLICATEVARIABLE" | wc -c) -gt 1 ]; then echo "variable duplicate found!"; printf "$CHECKDUPLICATEVARIABLE"; exit 1; fi

unit_test:
  stage: test
  script:
    - cp .env.example .env
    - composer install
    - php artisan key:generate
    - php artisan test

sensiolabs:
  stage: security-checker
  script:
    - local-php-security-checker composer.lock
  dependencies: []
  
deploy:
  stage: deploy
  script:
    - ssh -i ~/.ssh/id_rsa root@$IP_PUBLIC_SERVER "bash /opt/${DOMAIN}.sh"
  only:
    - develop

```
