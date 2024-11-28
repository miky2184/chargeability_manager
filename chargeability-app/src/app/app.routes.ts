import { Routes } from '@angular/router';
import { DashboardComponent } from './features/dashboard/dashboard.component';
import { TimeReportComponent } from './features/time-report/time-report.component';
import { EmployeeManagementComponent } from './features/employee-management/employee-management.component';
import { WbsComponent } from './features/wbs/wbs.component';
import { ChargeabilityComponent } from './features/chargeability/chargeability.component';

export const routes: Routes = [
  { path: '', redirectTo: 'dashboard', pathMatch: 'full' }, // Rotta di default
  { path: 'dashboard', component: DashboardComponent },
  { path: 'time-reports', component: TimeReportComponent },
  { path: 'employees', component: EmployeeManagementComponent },
  { path: 'wbs', component: WbsComponent },
  { path: 'chargeability', component: ChargeabilityComponent },
];
