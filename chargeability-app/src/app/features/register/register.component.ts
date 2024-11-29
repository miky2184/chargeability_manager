import { Component } from '@angular/core';
import { AuthService } from '../../services/auth.service';
import { CommonModule } from '@angular/common';
import { FormsModule } from '@angular/forms'; // Importa FormsModule

@Component({
  selector: 'app-register',
  standalone: true,
    imports: [CommonModule, FormsModule],
  templateUrl: './register.component.html',
})
export class RegisterComponent {
  username = '';
  password = '';
  email = '';
  full_name = '';

  constructor(private authService: AuthService) {}

  register(): void {
    const userData = {
      username: this.username,
      password: this.password,
      email: this.email,
      full_name: this.full_name
    };

    this.authService.register(userData).subscribe({
      next: (response) => console.log('Registrazione riuscita:', response),
      error: (err) => console.error('Errore nella registrazione:', err),
    });
  }
}
