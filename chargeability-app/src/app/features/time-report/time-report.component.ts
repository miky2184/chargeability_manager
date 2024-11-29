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
import { FormsModule } from '@angular/forms';


@Component({
  selector: 'app-time-report',
  standalone: true,
  imports: [CommonModule, FormsModule, MatButtonModule, NgxDatatableModule, MatTableModule, MatPaginatorModule, MatSortModule], // Importa CommonModule per direttive come *ngIf e *ngFor
  templateUrl: './time-report.component.html',
  styleUrls: ['./time-report.component.css'],
})
export class TimeReportComponent implements OnInit {
  timeReports: any[] = [];
  filteredData: any[] = [];
  isLoading = true;
  filters = {
    eid: '',
    wbs: '',
    fiscal_year: null,
    yy_cal: null,
    mm_cal: null
  };

  constructor(private timeReportsService: TimeReportsService) {}

  ngOnInit(): void {
    this.timeReportsService.getTimeReports().subscribe(
      (data) => {
        console.log('Dati ricevuti:', data); // Log dei dati per debug
        this.timeReports = data;
        this.filteredData = [...this.timeReports];
        this.isLoading = false;
      },
      (error) => {
        console.error('Errore durante il caricamento dei dati:', error);
        this.isLoading = false;
      }
    );
  }

  applyFilter(): void {
    this.filteredData = this.timeReports.filter((row) => {
      const matchesWbs = this.filters.wbs
        ? row.wbs.toLowerCase().includes(this.filters.wbs.toLowerCase())
        : true;
      const matchesYear = this.filters.fiscal_year
        ? row.fiscal_year === this.filters.fiscal_year
        : true;
     const matchesEid = this.filters.eid
      ? row.eid.toLowerCase().includes(this.filters.eid.toLowerCase())
      : true;
     const matchesYyCal = this.filters.yy_cal
        ? row.yy_cal === this.filters.yy_cal
        : true;
     const matchesMmCal = this.filters.mm_cal
        ? row.mm_cal.includes(String(this.filters.mm_cal))
        : true;

      return matchesWbs && matchesYear && matchesEid && matchesYyCal && matchesMmCal;
    });
  }

  exportToPDF(): void {
    const doc = new jsPDF();

    // Aggiungi titolo
    doc.setFontSize(16);
    doc.text('Report', 10, 10);

    // Genera la tabella
    autoTable(doc, {
      startY: 20,
      head: [['EID', 'WBS', 'FY', 'Anno', 'Mese', 'Quindicina', 'H Lavorate']],
      body: this.filteredData.map((report) => [
        report.eid,
        report.wbs,
        report.fiscal_year,
        report.yy_cal,
        report.mm_cal,
        report.project_name,
        report.fortnight,
        report.work_hh,
      ]),
    });

    // Salva il PDF
    doc.save('time-reports.pdf');
  }
}
