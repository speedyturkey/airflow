#!/usr/bin/env python

from datetime import datetime
import os
import subprocess
import sys
import time

from cryptography.fernet import Fernet

TRY_LOOP = 3
print("running python entrypoint")


def assign_default_value(env_var, value):
    """Assign default value for environment variable, if not already set"""
    if env_var not in os.environ:
        os.environ[env_var] = value
    return os.environ.get(env_var)


REDIS_HOST = assign_default_value('REDIS_HOST', 'REDIS-HOST')
REDIS_PORT = assign_default_value('REDIS_PORT', '6379')
REDIS_PASSWORD = assign_default_value('REDIS_PASSWORD', '')

POSTGRES_HOST = assign_default_value('POSTGRES_HOST', 'POSTGRESQL-HOST')
POSTGRES_PORT = assign_default_value('POSTGRES_PORT', '5432')
POSTGRES_USER = assign_default_value('POSTGRES_USER', 'USER')
POSTGRES_PASSWORD = assign_default_value('POSTGRES_PASSWORD', '******')
POSTGRES_DB = assign_default_value('POSTGRES_DB', 'postgres')

# Defaults and back-compat
FERNET_KEY = assign_default_value('FERNET_KEY', Fernet.generate_key().decode())
AIRFLOW__CORE__EXECUTOR = assign_default_value('AIRFLOW__CORE__EXECUTOR', 'CeleryExecutor')

# Load DAGs examples (default: Yes)
if 'AIRFLOW__CORE__LOAD_EXAMPLES' not in os.environ and assign_default_value('LOAD_EX', 'n') == 'n':
    os.environ['AIRFLOW__CORE__LOAD_EXAMPLES'] = 'False'

# Install custom python package if requirements.txt is present
if os.path.isfile('/requirements.txt'):
    subprocess.run(['pip', 'install', '--user', '-r', '/requirements.txt'])

if os.environ.get('REDIS_PASSWORD'):
    REDIS_PREFIX = f'{os.environ.get("REDIS_PASSWORD")}@'
else:
    REDIS_PREFIX = ''
os.environ['REDIS_PREFIX'] = REDIS_PREFIX


def nc(host, port):
    return subprocess.run(['nc', '-z', host, port]).returncode


def wait_for_port(name, host, port):
    iter_count = 1
    while nc(host, port) != 0:
        if iter_count > TRY_LOOP:
            print(f"{datetime.now()} - {host}:{port} still not reachable, giving up", file=sys.stderr)
            exit(1)
        print(f"{datetime.now()} - waiting for {name}... {iter_count}/{TRY_LOOP}")
        time.sleep(5)
        iter_count += 1


def wait_for_redis():
    if AIRFLOW__CORE__EXECUTOR == "CeleryExecutor":
        wait_for_port("Redis", REDIS_HOST, REDIS_PORT)


def create_user():
    import airflow
    from airflow import models, settings
    from airflow.contrib.auth.backends.password_auth import PasswordUser

    # Create Airflow User
    try:
        user = PasswordUser(models.User())
        user.username = 'wmcmonagle'
        user.email = 'william.mcmonagle@arcadia.com'
        user.password = 'yagni123'
        user.superuser = True
        session = settings.Session()
        session.add(user)
        session.commit()
        session.close()
        print('New User Created')
    except Exception as e:
        print(e)


AIRFLOW__CORE__SQL_ALCHEMY_CONN = assign_default_value(
    'AIRFLOW__CORE__SQL_ALCHEMY_CONN',
    f'postgresql+psycopg2://{POSTGRES_USER}:{POSTGRES_PASSWORD}@{POSTGRES_HOST}:{POSTGRES_PORT}/{POSTGRES_DB}'
)
AIRFLOW__CELERY__BROKER_URL = assign_default_value(
    'AIRFLOW__CELERY__BROKER_URL',
    f'redis://{REDIS_PREFIX}{REDIS_HOST}:{REDIS_PORT}/1'
)
AIRFLOW__CELERY__RESULT_BACKEND = assign_default_value(
    'AIRFLOW__CELERY__RESULT_BACKEND',
    f'db+postgresql://{POSTGRES_USER}:{POSTGRES_PASSWORD}@{POSTGRES_HOST}:{POSTGRES_PORT}/{POSTGRES_DB}'
)


if __name__ == '__main__':

    command = sys.argv[1]
    args = sys.argv[1:]

    if command == "webserver":
        wait_for_port("Postgres", POSTGRES_HOST, POSTGRES_PORT)
        wait_for_redis()
        subprocess.run(["airflow", "initdb"])
        create_user()
        if AIRFLOW__CORE__EXECUTOR == "LocalExecutor":
            # With the "Local" executor it should all run in one container.
            subprocess.Popen(["airflow", "scheduler"])
        os.execvp("airflow", ["airflow"] + args)
    elif command in ["worker", "scheduler"]:
        wait_for_port("Postgres", POSTGRES_HOST, POSTGRES_PORT)
        wait_for_redis()
        # To give the webserver time to run initdb.
        time.sleep(10)
        os.execvp("airflow", ["airflow"] + args)
    elif command == "flower":
        # wait_for_redis()
        os.execvp("airflow", ["airflow"] + args)
    elif command == "version":
        os.execvp("airflow", ["airflow"] + args)
    else:
        # The command is something like bash, not an airflow subcommand. Just run it in the right environment.
        os.execvp(sys.argv[1], sys.argv[1:])
