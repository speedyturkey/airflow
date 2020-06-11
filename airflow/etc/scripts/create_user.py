import airflow
from airflow import models, settings
from airflow.contrib.auth.backends.password_auth import PasswordUser

# Create Airflow User
user = PasswordUser(models.User())
user.username = 'wmcmonagle'
user.email = 'william.mcmonagle@arcadia.com'
user._set_password = 'yagni123'
session = settings.Session()
session.add(user)
session.commit()
session.close()
print('New User Created')
