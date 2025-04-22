#!/bin/bash
# Copyright (c) 2019 roga <roga@roga.tw>
# All rights reserved.
#
# mysql_backup.sh: Backup MySQL databases and keep newest 30 days backup using ZIP.

# Global variables
MYSQL="$(which mysql)"
MYSQLDUMP="$(which mysqldump)"

# Function to check if required arguments are provided
check_arguments() {
    if [ $# -lt 4 ]; then
        echo "Usage: $0 <db_user> <db_passwd> <db_host> <backup_dir>"
        echo "Example: $0 root password 127.0.0.1 /mnt/app-backup/mysql"
        exit 1
    fi
}

# Function to get list of databases to backup
get_databases() {
    local db_user="$1"
    local db_passwd="$2"
    local db_host="$3"
    
    $MYSQL -u "$db_user" -h "$db_host" -p"$db_passwd" -Bse "SHOW DATABASES;" | \
        grep -Ev "^(information_schema|performance_schema|mysql|sys)$"
}

# Function to backup a single database
backup_database() {
    local db="$1"
    local db_user="$2"
    local db_passwd="$3"
    local db_host="$4"
    local time="$5"
    local backup_dir="$6"
    
    local sql_file="$backup_dir/${time}.${db}.sql"
    local zip_file="$backup_dir/${time}.${db}.zip"

    echo "Backing up database: $db..."

    # Dump SQL file
    $MYSQLDUMP --default-character-set=utf8 --single-transaction --add-drop-table \
        -u "$db_user" -h "$db_host" -p"$db_passwd" "$db" > "$sql_file"

    # Compress with zip
    if zip -j "$zip_file" "$sql_file"; then
        rm "$sql_file"
        echo "Success: $zip_file created"
    else
        echo "Failed to compress $sql_file" >&2
    fi
}

# Function to clean up old backups
cleanup_old_backups() {
    local days="$1"
    local backup_dir="$2"
    echo "Cleaning up old backups..."
    find "$backup_dir" -type f -name "*.zip" -mtime +"$days" -exec rm -v {} \;
}

# Main function
main() {
    # Check arguments
    check_arguments "$@"
    
    # Set database credentials and backup directory
    local db_user="$1"
    local db_passwd="$2"
    local db_host="$3"
    local backup_dir="$4"
    
    # Create backup directory if not exists
    mkdir -p "$backup_dir"
    
    # Get current date
    local time="$(date +"%Y-%m-%d")"
    
    # Get list of databases to backup
    local dbs
    dbs=$(get_databases "$db_user" "$db_passwd" "$db_host")
    
    # Backup each database
    for db in $dbs; do
        backup_database "$db" "$db_user" "$db_passwd" "$db_host" "$time" "$backup_dir"
    done
    
    # Clean up old backups (30 days)
    cleanup_old_backups 30 "$backup_dir"
    
    echo "All done!"
}

# Execute main function
main "$@"
