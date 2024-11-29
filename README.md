# Chargeability Manager - Front End

ng build --configuration production

sudo systemctl restart nginx

sudo certbot certonly --manual --preferred-challenges dns -d miky2184.ddns.net  

Certificate is saved at: /etc/letsencrypt/live/miky2184.ddns.net/fullchain.pem
Key is saved at:         /etc/letsencrypt/live/miky2184.ddns.net/privkey.pem

Progetto: WBS & Chargeability App Manager

Questa guida dettagliata descrive i passaggi necessari per creare, configurare e deployare l’applicazione WBS & Chargeability App Manager. Il progetto include funzionalità di login, logout, registrazione utente, gestione delle WBS e time reports. È composto da un backend in FastAPI, un frontend in Angular standalone, un database PostgreSQL e un server Ubuntu per il deploy.

Requisiti

Generali

	•	Sistema operativo: Ubuntu Server (preferibilmente 20.04 o successivo).
	•	Node.js: Versione 18 o successiva.
	•	Angular CLI: Versione 15 o successiva.
	•	Python: Versione 3.10 o successiva.
	•	PostgreSQL: Versione 12 o successiva.

Librerie e strumenti

	•	npm, pip, nginx, certbot, pm2 per la gestione dei processi.

1. Configurazione del Backend

1.1. Installazione di FastAPI

Installiamo FastAPI e le librerie necessarie:

sudo apt update
sudo apt install python3 python3-pip python3-venv -y

# Creazione e attivazione di un ambiente virtuale
python3 -m venv venv
source venv/bin/activate

# Installazione delle librerie
pip install fastapi uvicorn psycopg2 pydantic python-jose[cryptography]

1.2. Struttura del Backend

Crea la seguente struttura di file:

backend/
├── main.py
├── models/
│   ├── user.py
│   ├── time_report.py
│   └── wbs.py
├── routers/
│   ├── auth.py
│   ├── time_reports.py
│   └── wbs.py
├── services/
│   ├── auth_service.py
│   └── db_service.py
├── utils/
│   ├── jwt_helper.py
│   └── hashing.py
└── requirements.txt

1.3. File di Esempio

1.3.1. main.py

from fastapi import FastAPI
from routers import auth, time_reports, wbs

app = FastAPI()

# Registra i router
app.include_router(auth.router)
app.include_router(time_reports.router)
app.include_router(wbs.router)

@app.get("/")
async def root():
    return {"message": "WBS & Chargeability App Manager Backend"}

1.3.2. Configurazione del Database

Crea un file services/db_service.py per connetterti al database:

import psycopg2
from psycopg2.extensions import connection

def get_db_connection() -> connection:
    return psycopg2.connect(
        host="localhost",
        database="chargeability",
        user="postgres",
        password="password"
    )

1.3.3. Endpoint per la Registrazione (auth.py)

from fastapi import APIRouter, HTTPException, Body
from models.user import UserRegister
from services.db_service import get_db_connection

router = APIRouter(prefix="/auth", tags=["auth"])

@router.post("/register")
async def register_user(user: UserRegister):
    conn = get_db_connection()
    cursor = conn.cursor()

    # Controlla se l'utente esiste già
    cursor.execute("SELECT * FROM users WHERE username = %s", (user.username,))
    if cursor.fetchone():
        raise HTTPException(status_code=400, detail="Username già in uso")

    # Inserisce l'utente nel database
    cursor.execute(
        "INSERT INTO users (username, password, email) VALUES (%s, %s, %s)",
        (user.username, user.password, user.email)
    )
    conn.commit()
    cursor.close()
    conn.close()

    return {"message": "Registrazione completata"}

2. Configurazione del Frontend

2.1. Installazione di Angular

# Installa Angular CLI
npm install -g @angular/cli

# Crea il progetto
ng new chargeability-app --standalone
cd chargeability-app

2.2. Implementazione del Login

Crea il componente login

ng generate component features/login

Aggiorna login.component.html:

<h2>Login</h2>
<form (ngSubmit)="login()">
  <div>
    <label for="username">Username</label>
    <input type="text" id="username" [(ngModel)]="username" name="username" required />
  </div>
  <div>
    <label for="password">Password</label>
    <input type="password" id="password" [(ngModel)]="password" name="password" required />
  </div>
  <button type="submit">Login</button>
</form>

Aggiorna login.component.ts:

import { Component } from '@angular/core';
import { AuthService } from '../../services/auth.service';

@Component({
  selector: 'app-login',
  templateUrl: './login.component.html',
})
export class LoginComponent {
  username = '';
  password = '';

  constructor(private authService: AuthService) {}

  login(): void {
    this.authService.login(this.username, this.password).subscribe({
      next: (response) => {
        console.log('Login riuscito:', response);
      },
      error: (err) => {
        console.error('Errore di login:', err);
      },
    });
  }
}

2.3. Aggiungi l’Interceptor per il Token

Crea l’interceptor auth.interceptor.ts:

import { HttpInterceptorFn } from '@angular/common/http';
import { inject } from '@angular/core';
import { AuthService } from '../services/auth.service';

export const authInterceptor: HttpInterceptorFn = (req, next) => {
  const authService = inject(AuthService);
  const token = authService.getToken();

  if (token) {
    const authReq = req.clone({
      setHeaders: {
        Authorization: `Bearer ${token}`,
      },
    });
    return next(authReq);
  }

  return next(req);
};

Registra l’interceptor in app.config.ts:

import { provideHttpClient, withInterceptors } from '@angular/common/http';
import { authInterceptor } from './core/interceptors/auth.interceptor';

export const appConfig: ApplicationConfig = {
  providers: [
    provideHttpClient(withInterceptors([authInterceptor])),
  ],
};

3. Configurazione del Database

3.1. Crea il Database

CREATE DATABASE chargeability;

-- Tabella utenti
CREATE TABLE users (
    id SERIAL PRIMARY KEY,
    username VARCHAR(100) UNIQUE NOT NULL,
    password VARCHAR(255) NOT NULL,
    email VARCHAR(255) UNIQUE NOT NULL
);

4. Deploy

4.1. Deploy del Backend

	1.	Installa pm2 per gestire il processo:

npm install -g pm2


	2.	Avvia il backend con pm2:

pm2 start uvicorn --name chargeability-backend -- main:app --host 0.0.0.0 --port 4000

4.2. Configura Nginx

Configura Nginx per gestire le richieste:

server {
    listen 80;
    server_name miky2184.ddns.net;

    location / {
        proxy_pass http://127.0.0.1:4200;
        proxy_http_version 1.1;
        proxy_set_header Upgrade $http_upgrade;
        proxy_set_header Connection 'upgrade';
        proxy_set_header Host $host;
        proxy_cache_bypass $http_upgrade;
    }

    location /api/ {
        proxy_pass http://127.0.0.1:4000;
        proxy_http_version 1.1;
        proxy_set_header Upgrade $http_upgrade;
        proxy_set_header Connection 'upgrade';
        proxy_set_header Host $host;
        proxy_cache_bypass $http_upgrade;
    }
}

Riavvia Nginx:

sudo systemctl restart nginx

5. HTTPS con Certbot

	1.	Installa Certbot:

sudo apt install certbot python3-certbot-nginx -y


	2.	Genera il certificato:

sudo certbot --nginx -d miky2184.ddns.net

Questa guida copre tutti i passaggi per sviluppare, configurare e deployare il progetto. Se hai bisogno di ulteriori dettagli, fammi sapere! 😊