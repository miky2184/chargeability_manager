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
  wbsData: any[] = [];
  isLoading = true;
  selectedWbs: any = {};

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
        console.error('Errore durante il caricamento della tabella WBS:', error);
        this.isLoading = false;
      }
    );
  }

  addWbs(newWbs: any): void {
    this.wbsService.createWbs(newWbs).subscribe(() => this.loadWbs());
  }

  updateWbs(updatedWbs: any): void {
    this.wbsService.updateWbs(updatedWbs.wbs, updatedWbs).subscribe(() => this.loadWbs());
  }

  deleteWbs(id: string): void {
    this.wbsService.deleteWbs(id).subscribe(() => this.loadWbs());
  }

  selectWbs(wbs: any): void {
    this.selectedWbs = { ...wbs }; // Crea una copia dei dati selezionati
  }

  clearSelection(): void {
    this.selectedWbs = null;
  }
}
