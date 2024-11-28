import { ApplicationConfig } from '@angular/core';
import { provideRouter } from '@angular/router';
import { routes } from './app.routes';
import { provideHttpClient } from '@angular/common/http';
import { provideAnimationsAsync } from '@angular/platform-browser/animations/async';

export const appConfig: ApplicationConfig = {
  providers: [
    provideHttpClient(), // Aggiungi il supporto per le richieste HTTP
    provideRouter(routes), provideAnimationsAsync(), // Configura il router con le rotte definite
  ],
};
