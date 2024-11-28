import { Component, OnInit } from '@angular/core';
import { CommonModule } from '@angular/common';
import { TimeReportsService } from './time-reports.service';

@Component({
  selector: 'app-time-report',
  standalone: true,
  imports: [CommonModule], // Importa CommonModule per direttive come *ngIf e *ngFor
  templateUrl: './time-report.component.html',
  styleUrls: ['./time-report.component.css'],
})
export class TimeReportComponent implements OnInit {
  timeReports: any[] = [];
  isLoading = true;

  constructor(private timeReportsService: TimeReportsService) {}

  ngOnInit(): void {
    this.timeReportsService.getTimeReports().subscribe(
      (data) => {
        console.log('Dati ricevuti:', data); // Log dei dati per debug
        this.timeReports = data;
        this.isLoading = false;
      },
      (error) => {
        console.error('Errore durante il caricamento dei dati:', error);
        this.isLoading = false;
      }
    );
  }
}
