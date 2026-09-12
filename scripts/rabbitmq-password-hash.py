#!/usr/bin/env python3
# RabbitMQ's salted-SHA256 hash format: base64(salt(4B) + sha256(salt + password)).
# https://www.rabbitmq.com/docs/passwords#computing-password-hash
import base64
import hashlib
import os
import sys

password = os.environ["RABBITMQ_PASSWORD"].encode()
salt = hashlib.sha256(password).digest()[:4]
digest = hashlib.sha256(salt + password).digest()
sys.stdout.write(base64.b64encode(salt + digest).decode())
