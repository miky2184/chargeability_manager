import { Component, OnInit } from '@angular/core';
import { WbsService } from './wbs.service';
import { CommonModule } from '@angular/common';
import { FormsModule } from '@angular/forms'; // Importa FormsModule
import { MatButtonModule } from '@angular/material/button';
import { NgxDatatableModule } from '@swimlane/ngx-datatable';
import { MatTableModule } from '@angular/material/table';
import { MatPaginatorModule } from '@angular/material/paginator';
import { MatSortModule } from '@angular/material/sort';

@Component({
  selector: 'app-wbs',
  standalone: true,
  imports: [CommonModule, FormsModule, MatButtonModule, NgxDatatableModule, MatTableModule, MatPaginatorModule, MatSortModule],
  templateUrl: './wbs.component.html',
  styleUrls: ['./wbs.component.css'],
})
export class WbsComponent implements OnInit {
  wbsData: any[] = []; // Dati della tabella
  selectedWbs: any = {
  wbs: '',
  wbs_type: '',
  project_name: '',
  budget_mm: null,
  budget_tot: null,
}; // Riga selezionata
  isLoading = true;

  constructor(private wbsService: WbsService) {}

  ngOnInit(): void {
    this.loadWbs();
  }

  loadWbs(): void {
    this.wbsService.getWbs().subscribe(
      (data) => {
        this.wbsData = data;
        this.isLoading = false;
      },
      (error) => {
        console.error('Errore durante il caricamento dei dati:', error);
        this.isLoading = false;
      }
    );
  }

  onCheckboxChange(row: any): void {
    if (this.selectedWbs?.wbs === row.wbs) {
      this.clearSelection(); // Deseleziona se cliccato di nuovo
    } else {
      this.selectedWbs = { ...row }; // Copia i dati della riga selezionata
    }
  }

  clearSelection(): void {
  this.selectedWbs = {
    wbs: '',
    wbs_type: '',
    project_name: '',
    budget_mm: null,
    budget_tot: null,
    salvata: false
  };
}

  addWbs(newWbs: any): void {
    this.wbsService.createWbs(newWbs).subscribe(() => {
      this.loadWbs();
      this.clearSelection();
    });
  }

  updateWbs(updatedWbs: any): void {
    this.wbsService.updateWbs(updatedWbs.wbs, updatedWbs).subscribe(() => {
      this.loadWbs();
      this.clearSelection();
    });
  }

  deleteWbs(wbs: string): void {
    this.wbsService.deleteWbs(wbs).subscribe(() => {
      this.loadWbs();
      this.clearSelection();
    });
  }
}
