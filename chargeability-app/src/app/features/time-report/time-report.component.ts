import { Component, OnInit } from '@angular/core';
import { CommonModule } from '@angular/common';
import { TimeReportsService } from './time-reports.service';
import { jsPDF } from 'jspdf';
import autoTable from 'jspdf-autotable';
import { MatButtonModule } from '@angular/material/button';
import { NgxDatatableModule } from '@swimlane/ngx-datatable';
import { MatTableModule } from '@angular/material/table';
import { MatPaginatorModule } from '@angular/material/paginator';
import { MatSortModule } from '@angular/material/sort';


@Component({
  selector: 'app-time-report',
  standalone: true,
  imports: [CommonModule, MatButtonModule, NgxDatatableModule, MatTableModule, MatPaginatorModule, MatSortModule], // Importa CommonModule per direttive come *ngIf e *ngFor
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

  exportToPDF(): void {
    const doc = new jsPDF();

    // Aggiungi titolo
    doc.setFontSize(16);
    doc.text('Time Reports', 10, 10);

    // Genera la tabella
    autoTable(doc, {
      startY: 20,
      head: [['EID', 'Anno', 'Mese', 'Progetto', 'Ore (TR1)', 'Ore (TR2)']],
      body: this.timeReports.map((report) => [
        report.eid,
        report.yy_cal,
        report.mm_cal,
        report.project_name,
        report.work_hh_tr1,
        report.work_hh_tr2,
      ]),
    });

    // Salva il PDF
    doc.save('time-reports.pdf');
  }
}
