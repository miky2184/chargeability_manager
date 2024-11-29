import { Injectable } from '@angular/core';
import { Router } from '@angular/router';

@Injectable({
  providedIn: 'root',
})
export class AuthService {
  private isAuthenticated = false;

  constructor(private router: Router) {}

  login(username: string, password: string): boolean {
    // Mock: sostituisci con una chiamata HTTP al tuo backend
    if (username === 'admin' && password === 'password') {
      this.isAuthenticated = true;
      return true;
    }
    return false;
  }

  logout(): void {
    this.isAuthenticated = false;
    localStorage.removeItem('access_token'); // Rimuovi il token dal local storage
    this.router.navigate(['/login']); // Reindirizza alla pagina di login
  }

  isLoggedIn(): boolean {
    return this.isAuthenticated;
  }
}
