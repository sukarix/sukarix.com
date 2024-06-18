#!/bin/bash

# Author(s):
#       Ghazi Triki <ghazi.triki@riadvice.tn>
#
# Changelog:
#   2024-06-17 GTR Initial Version

# The real location of the script
SCRIPT=$(readlink -f "$0")

# Current unix username
USER=$(whoami)

# Directory where the script is located
BASEDIR=$(dirname "$SCRIPT")

# Formatted current date
NOW=$(date +"%Y-%m-%d_%H.%M.%S")

# Production Sukarix Application directory
APP_DIR=$BASEDIR/../

# Current git branch name transforms '* dev-0.5' to 'dev-0.5'
GIT_BRANCH=$(git --git-dir="$BASEDIR/../.git" branch | sed -n '/\* /s///p')

# Git tag, commits ahead & commit id under format '0.4-160-g3bb256c'
GIT_VERSION=$(git --git-dir="$BASEDIR/../.git" describe --tags --always HEAD)

#
# Display usage
#
usage() {
  echo
  echo "#========================================================================================================"
  echo "#"
  echo "# Sukarix Configuration Utility for the Sukarix PHP Frameowk - Version $GIT_VERSION on $GIT_BRANCH branch"
  echo "#"
  echo "#    sukarix [options]"
  echo "#"
  echo "# Configuration:"
  echo "#    --version                        Display Sukarix application version"
  echo "#    --selfinstall                    Make sukarix runnable from anywhere"
  echo "#"
  echo "# Development:"
  echo "#    --enabletests                    Enable running unit tests"
  echo "#    --test <-c> <name>               Run unit tests with a test name. Use for -c coverage"
  echo "#    --fix                            Fix php code style"
  echo "#    --migrate                        Run database migrations"
  echo "#    --metrics                        Generates code metrics"
  echo "#"
  echo "# Monitoring:"
  echo "#    --check                          Check configuration files and processes for problems"
  echo "#"
  echo "# Administration:"
  echo "#    --pull                           Pull source code from its repository"
  echo "#    --deploy                         Deploy the application on a production server"
  echo "#    --build-docs                     Build the documentation"
  echo "#    --jobs                           Install the cron jobs"
  echo "#    --restart                        Restart Sukarix Stack"
  echo "#    --stop                           Stop Sukarix Stack"
  echo "#    --start                          Start Sukarix Stack"
  echo "#    --clean                          Restart and clean all log files"
  echo "#    --cleansessions                  Cleans sessions from the database"
  echo "#    --status                         Display running status of components"
  echo "#    --zip                            Zip up log files for reporting an error"
  echo "#"
  echo "#========================================================================================================"
  echo
}

#
# Check file
#
check_file() {
  if [ ! -f "$1" ]; then
    echo "✘ File does not exist: $1"
    # m option means that the file is mandatory and the script cannot continue running
    if [ "$2" == "m" ]; then
      echo "✘ File $1 is mandatory. Script execution is interrupted"
      exit 1
    fi
  fi
}

need_production() {
  if [ "$ENVIRONMENT" != "production" ]; then
    echo "✘ Command can only be run in production environment"
    exit 1
  fi
}

#
# Display installed Sukarix Stack & servers version
#
display_version() {
  echo "■ Application :  $GIT_VERSION"
  echo "■ Nginx       :  $(nginx -v)"
  echo "■ PHP         :  $(php -v | sed -n 1p)"
  echo "■ Redis       :  $(redis-server --version)"
  echo "■ PostgreSQL  :  $(psql -V)"
}

#
# Install sukarix to make runnable from anywhere
#
self_install() {
  if [ -f /usr/local/bin/sukarix ]; then
    echo "✘ sukarix already installed"
  else
    sudo ln -s "$SCRIPT" /usr/local/bin/sukarix
    echo "✔ sukarix successfully installed"
  fi
}

#
# Clean server status
#
display_status() {
  units="nginx php-fpm postgresql redis"
  echo
  line='————————————————————►'
  for unit in $units; do
    if [ $(pgrep -c "$unit") != 0 ]; then
      printf "%s %s [✔ - UP]\n" $unit "${line:${#unit}}"
    else
      printf "%s %s [✘ - DOWN]\n" $unit "${line:${#unit}}"
    fi
  done
  echo
}

#
# Clean Sukarix Application cache
#
clean_cache() {
  echo "► Deleting cache"
  find "$BASEDIR/../bin/" ! -name '.gitkeep' -type f -exec rm -rfv {} \;
  find "$BASEDIR/../tmp/" ! -name '.gitkeep' -type f -exec rm -rfv {} \;
  find "$BASEDIR/../tmp/cache/" ! -name '.gitkeep' -type f -exec rm -rfv {} \;
  find "$BASEDIR/../tmp/mail/" -name '*.eml' -type f -exec rm -v {} \;
  find "$BASEDIR/../uploads/tmp/" -type f -exec rm -v {} \;
  find "$BASEDIR/../public/minified/" ! -name '.gitkeep' -type f -exec rm -v {} \;
  echo "✔ Cache deleted"
}

#
# Clean Sukarix logs
#
clean_logs() {
  echo "► Cleaning logs"

  find "$BASEDIR/../logs/" ! -name '.gitkeep' -type f -exec rm -v {} \;

  echo "✔ Cleaned logs folder"
}

#
# Clean sessions from the database
#
clean_sessions() {
  sudo -u postgres psql -d sukarix -c "SELECT setval('users_sessions_id_seq'::regclass, 1);"
  sudo -u postgres psql -d sukarix -c "TRUNCATE users_sessions;"
}

#
# Archive logs for debugging
#
zip_logs() {
  echo "► Archiving logs"

  ARCHIVE="/home/$USER/logs/logs-$NOW.tar.gz"
  mkdir -p "/home/$USER/logs/"

  touch /tmp/empty
  tar cfv "$ARCHIVE" /tmp/empty
  tar rfv "$ARCHIVE" "$BASEDIR/../logs/" --exclude='.gitkeep'
  sudo tar rfv "$ARCHIVE" /var/log/nginx/
  echo "✔ Logs archived at $ARCHIVE"
}

#
# Run PHP Code Style Fixer
#
fix_styles() {
  echo "► Running PHP Code Style Fixer"

  cd "$BASEDIR/../"

  sudo phpdismod -s cli xdebug
  PHP_CS_FIXER_IGNORE_ENV=true ./vendor/bin/php-cs-fixer fix --allow-risky=yes
  sudo phpenmod -s cli xdebug
  echo "✔ PHP Code Style Fixed"
}

#
# Enable unit tests
#
enable_tests() {
  echo "► Enabling unit tests"

  rm -rfv "$BASEDIR/../public/statera/"
  mkdir -pv "$BASEDIR/../public/statera/coverage/"
  mkdir -pv "$BASEDIR/../public/statera/result/"
  cp -Rv "$BASEDIR/../vendor/sukarix/statera/statera.php" "$BASEDIR/../public/statera/index.php"
  cp -Rv "$BASEDIR/../vendor/sukarix/statera/ui/css" "$BASEDIR/../public/statera/"
  cp -Rv "$BASEDIR/../vendor/sukarix/statera/ui/images" "$BASEDIR/../public/statera/"
  cp -Rv "$BASEDIR/../vendor/sukarix/statera/ui/css" "$BASEDIR/../public/statera/result"
  cp -Rv "$BASEDIR/../vendor/sukarix/statera/ui/images" "$BASEDIR/../public/statera/result"
  cp "$BASEDIR/../vendor/bcosca/fatfree-core/code.css" "$BASEDIR/../public/statera/css/code.css"
  cp "$BASEDIR/../vendor/bcosca/fatfree-core/code.css" "$BASEDIR/../public/statera/result/css/code.css"

  echo "✔ Unit tests enabled"
}

#
# Run unit test in CLI mode
#
run_tests() {
  echo "► Running unit tests"

  if [ ! -d "$BASEDIR/../public/statera/" ]; then
      echo "Directory public/statera/ does not exist. Please run 'sukarix --enable-tests' first"
      exit 1  # Exit with a status of 1 to indicate an error
  fi

  COVERAGE=$1
  USE_COVERAGE=""
  TEST_NAME="all"

  if [[ "$1" != "-c" ]]; then
    if [[ "$1" != "" ]]; then
      TEST_NAME=$1
    fi

    if [[ "$2" == "-c" ]]; then
      USE_COVERAGE="=withCoverage"
    fi
  fi

  if [[ "$1" == "-c" ]]; then
    USE_COVERAGE="=withCoverage"
    if [[ "$2" != "" ]]; then
      TEST_NAME=$2
    fi
  fi

  cd $(dirname "$BASEDIR")
  # Revert database base to the initial state then create it again
  "vendor/bin/phinx" rollback -e testing -t 0 -vvv
  "vendor/bin/phinx" migrate -e testing -vvv

  cd "public"

  XDEBUG_MODE=coverage php index.php "/?statera$USE_COVERAGE&test=$TEST_NAME" -o="../public/statera/result/index.html"

  SUCCESS=$(cat "statera/test.result")
  if [[ "$SUCCESS" == "success" ]]; then
    echo "✔ Test success"
    exit 0
  else
    echo "✘ Test fail"
    exit 1
  fi
}

#
# Install the cron jobs
#
install_cron_job() {
  echo "► Installing cron jobs"
  if [ "$ENVIRONMENT" != "production" ]; then
    sudo crontab -u www-data "$BASEDIR/../tools/sukarix-tasks-dev"
  else
    sudo crontab -u www-data "$BASEDIR/../tools/sukarix-tasks"
  fi
  sudo /etc/init.d/cron reload
}

#
# Updates composer and reset user home composer ownership
#
update_composer() {
  echo "► Updating composer"
  sudo composer selfupdate
  sudo chown -R "$USER:$USER" "/home/$USER/.composer/"
}

#
# Fetch the source code from its repository
#
update_source_code() {
  need_production
  echo "► Pulling source code in $APP_DIR"
  cd "$APP_DIR"
  git pull
}

# Install composer dependencies
#
install_dependencies() {
  cd $(dirname "$BASEDIR")
  echo "► Updating composer dependencies"
  composer install -o --no-dev
}

#
# Run database migrations
#
run_migrations() {
  echo "► Running database migration"
  cd $(dirname "$BASEDIR")
  vendor/bin/phinx migrate -e "$ENVIRONMENT"
}

#
# Generate code quality metrics
#
generate_metrics() {
  vendor/bin/phpmetrics --report-html="$BASEDIR/../public/metrics" "$BASEDIR/../app/src/"
}

#
# Give folders right permissions
#
chmod_folders() {
  cd "$APP_DIR"
  sudo chmod -R 755 -R "$BASEDIR/../data/"
  sudo chmod -R 766 -R "$BASEDIR/../logs/"
  sudo chmod -R 766 -R "$BASEDIR/../tmp/"
  sudo chmod -R 755 -R "$BASEDIR/../uploads/"
  sudo chmod -R 755 -R "$BASEDIR/../public/minified/"
  sudo usermod -a -G devops www-data
}

#
# Fully deploys all the application
#
deploy_application() {
  need_production
  cd "$APP_DIR"
  sudo chown -R "$USER:$USER" .
  sudo find "$APP_DIR/tmp" -type f -name "*.php" -exec rm -v {} +
  update_source_code
  update_composer
  install_dependencies
  run_migrations
  cd "$APP_DIR"
  sudo chown -R "www-data:www-data" .
  chmod_folders
  install_cron_job
  reload_services
}

#
# Start services
#
start_services() {
  sudo service postgresql start
  sudo service redis-server start
  sudo service nginx start
  sudo service php8.3-fpm start
}

#
# Stop services
#
stop_services() {
  sudo service postgresql stop
  sudo service redis-server stop
  sudo service nginx stop
  sudo service php8.3-fpm stop
}

#
# Restart services
#
restart_services() {
  sudo service postgresql restart
  sudo service redis-server restart
  sudo service nginx restart
  sudo service php8.3-fpm restart
}

reload_services() {
  sudo service postgresql reload
  sudo service redis-server force-reload
  sudo service nginx reload
  sudo service php8.3-fpm reload
}

run() {
  if [[ $# -eq 0 ]]; then
    usage
    exit 1
  fi

  # Environment
  HOST_TESTER=$(hostname)
  if [[ "$HOST_TESTER" == "sukarix.test" ]]; then
    ENVIRONMENT="development"
  else
    ENVIRONMENT="production"
  fi

  echo "► Detected environment: \`$ENVIRONMENT\`"

  while [[ $# -gt 0 ]]; do

    if [ "$1" = "--version" -o "$1" = "-version" -o "$1" = "-v" ]; then
      display_version
      shift
      continue
    fi

    if [ "$1" = "--selfinstall" -o "$1" = "-selfinstall" -o "$1" = "-si" ]; then
      self_install
      shift
      continue
    fi

    if [ "$1" = "--enabletests" -o "$1" = "-enabletests" -o "$1" = "-e" ]; then
      enable_tests
      shift
      continue
    fi

    if [ "$1" = "--test" -o "$1" = "-test" -o "$1" = "-t" ]; then
      run_tests "$2" "$3"

      shift
      shift
      continue
    fi

    if [ "$1" = "--check" -o "$1" = "-check" ]; then
      # todo: apache config, mysql config, directories permissions...
      echo "not implemented yet"
      shift
      continue
    fi

    if [ "$1" = "--fix" -o "$1" = "-fix" -o "$1" = "-f" ]; then
      fix_styles
      shift
      continue
    fi

    if [ "$1" = "--migrate" -o "$1" = "-migrate" -o "$1" = "-m" ]; then
      run_migrations
      shift
      continue
    fi

    if [ "$1" = "--metrics" -o "$1" = "-metrics" -o "$1" = "-me" ]; then
      generate_metrics
      shift
      continue
    fi

    if [ "$1" = "--clean" -o "$1" = "-clean" ]; then
      clean_cache
      clean_logs
      shift
      continue
    fi

    if [ "$1" = "--cleansessions" -o "$1" = "-cleansessions" -o "$1" = "-cs" ]; then
      clean_sessions
      shift
      continue
    fi

    if [ "$1" = "--pull" -o "$1" = "-pull" -o "$1" = "-p" ]; then
      update_source_code
      shift
      continue
    fi

    if [ "$1" = "--install" -o "$1" = "-install" -o "$1" = "-i" ]; then
      install_server
      shift
      continue
    fi

    if [ "$1" = "--deploy" -o "$1" = "-deploy" -o "$1" = "-d" ]; then
      deploy_application
      shift
      continue
    fi

    if [ "$1" = "--jobs" -o "$1" = "-jobs" -o "$1" = "-j" ]; then
      install_cron_job
      shift
      continue
    fi

    if [ "$1" = "--restart" -o "$1" = "-restart" -o "$1" = "-r" ]; then
      restart_services
      shift
      continue
    fi

    if [ "$1" = "--stop" -o "$1" = "-stop" -o "$1" = "-sp" ]; then
      stop_services
      shift
      continue
    fi

    if [ "$1" = "--start" -o "$1" = "-start" -o "$1" = "-sr" ]; then
      start_services
      shift
      continue
    fi

    if [ "$1" = "--status" -o "$1" = "-status" ]; then
      display_status
      shift
      continue
    fi

    if [ "$1" = "--zip" -o "$1" = "-zip" -o "$1" = "-z" ]; then
      zip_logs
      shift
      continue
    fi

    usage
    exit 1

  done
}

run "$@" #2>&1 | tee -a "$BASEDIR/../logs/sukarix-$NOW.log"
