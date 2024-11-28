import { NgModule } from '@angular/core';
import { CommonModule } from '@angular/common';
import { NavbarComponent } from '../shared/navbar/navbar.component';
import { FooterComponent } from '../shared/footer/footer.component';

@NgModule({
  declarations: [
    NavbarComponent, // Dichiarazione del componente Navbar
    FooterComponent, // Dichiarazione del componente Footer
  ],
  imports: [
    CommonModule, // Necessario per le direttive Angular di base
  ],
  exports: [
    NavbarComponent, // Esporta il componente Navbar
    FooterComponent, // Esporta il componente Footer
  ],
})
export class CoreModule {}
