import { NgModule } from '@angular/core';
import { CommonModule } from '@angular/common';
import { FormsModule } from '@angular/forms';
import { NavbarComponent } from '../shared/navbar/navbar.component';
import { FooterComponent } from '../shared/footer/footer.component';
import { HTTP_INTERCEPTORS } from '@angular/common/http';
import { AuthInterceptor } from './interceptors/auth.interceptor';

@NgModule({
  declarations: [
    NavbarComponent, // Navbar
    FooterComponent, // Footer
  ],
  imports: [
    CommonModule, // Direttive come *ngIf e *ngFor
    FormsModule,  // Per [(ngModel)]
  ],
  exports: [
    NavbarComponent, // Per essere usato in altri moduli
    FooterComponent, // Per essere usato in altri moduli
  ],
  providers: [
    { provide: HTTP_INTERCEPTORS, useClass: AuthInterceptor, multi: true },
  ],
})
export class CoreModule {}
