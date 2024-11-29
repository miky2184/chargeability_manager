import { Routes } from '@angular/router';
import { DashboardComponent } from './features/dashboard/dashboard.component';
import { TimeReportComponent } from './features/time-report/time-report.component';
import { EmployeeManagementComponent } from './features/employee-management/employee-management.component';
import { WbsComponent } from './features/wbs/wbs.component';
import { ChargeabilityComponent } from './features/chargeability/chargeability.component';
import { LoginComponent } from './features/login/login.component'; // Importa il componente di login
import { AuthGuard } from './guards/auth.guard';
import { RegisterComponent } from './features/register/register.component'; // Importa il componente di register

export const routes: Routes = [
  { path: 'login', component: LoginComponent }, // Rotta per il login
  { path: 'register', component: RegisterComponent },
  { path: '', redirectTo: 'dashboard', pathMatch: 'full' }, // Rotta di default
  {
    path: 'dashboard',
    component: DashboardComponent,
    canActivate: [AuthGuard], // Protezione con AuthGuard
  },
  {
    path: 'time-reports',
    component: TimeReportComponent,
    canActivate: [AuthGuard],
  },
  {
    path: 'employees',
    component: EmployeeManagementComponent,
    canActivate: [AuthGuard],
  },
  {
    path: 'wbs',
    component: WbsComponent,
    canActivate: [AuthGuard],
  },
  {
    path: 'chargeability',
    component: ChargeabilityComponent,
    canActivate: [AuthGuard],
  },
];
