#!/usr/bin/env bash
mysql -uroot -p${MYSQL_ROOT_PASSWORD} < /scripts/create-stock-tables.sql