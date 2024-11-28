import { Component } from '@angular/core';
import { RouterOutlet } from '@angular/router';
import { NavbarComponent } from './shared/navbar/navbar.component';
import { FooterComponent } from './shared/footer/footer.component';

@Component({
  selector: 'app-root',
  standalone: true, // Definisce che è un componente standalone
  imports: [RouterOutlet, NavbarComponent, FooterComponent], // Importa RouterOutlet e NavbarComponent
  templateUrl: './app.component.html',
  styleUrls: ['./app.component.css'],
})
export class AppComponent {
  title = 'WBS & Chargeability App Manager';
}
