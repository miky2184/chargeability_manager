import { Component, OnInit } from '@angular/core';
import { ResourceService } from './employee-management.service';
import { CommonModule } from '@angular/common';
import { FormsModule } from '@angular/forms'; // Importa FormsModule
import { MatButtonModule } from '@angular/material/button';
import { NgxDatatableModule } from '@swimlane/ngx-datatable';
import { MatTableModule } from '@angular/material/table';
import { MatPaginatorModule } from '@angular/material/paginator';
import { MatSortModule } from '@angular/material/sort';

@Component({
  selector: 'app-employee-management',
 standalone: true,
  imports: [CommonModule, FormsModule, MatButtonModule, NgxDatatableModule, MatTableModule, MatPaginatorModule, MatSortModule],
  templateUrl: './employee-management.component.html',
  styleUrl: './employee-management.component.css'
})
export class EmployeeManagementComponent implements OnInit {
    resourceData: any[] = []; // Dati della tabella
  selectedResource: any = {
    eid: '',
    last_name: '',
    first_name: '',
    level: null,
    loaded_cost: null,
    office: '',
    dte: '',
    salvata: false
}; // Riga selezionata
  isLoading = true;

  constructor(private resourceService: ResourceService) {}

  ngOnInit(): void {
    this.loadResource();
  }

  loadResource(): void {
    this.resourceService.getResource().subscribe(
      (data) => {
        this.resourceData = data;
        this.isLoading = false;
      },
      (error) => {
        console.error('Errore durante il caricamento dei dati:', error);
        this.isLoading = false;
      }
    );
}

  onCheckboxChange(row: any): void {
    if (this.selectedResource?.eid === row.eid) {
      this.clearSelection(); // Deseleziona se cliccato di nuovo
    } else {
      this.selectedResource = { ...row }; // Copia i dati della riga selezionata
    }
  }

  clearSelection(): void {
  this.selectedResource = {
    eid: '',
    last_name: '',
    first_name: '',
    level: null,
    loaded_cost: null,
    office: '',
    dte: '',
    salvata: false
  };
}

  addResource(newResource: any): void {
    this.resourceService.createResource(newResource).subscribe(() => {
      this.loadResource();
      this.clearSelection();
    });
  }

  updateResource(updatedResource: any): void {
    this.resourceService.updateResource(updatedResource.eid, updatedResource).subscribe(() => {
      this.loadResource();
      this.clearSelection();
    });
  }

  deleteResource(eid: string): void {
    this.resourceService.deleteResource(eid).subscribe(() => {
      this.loadResource();
      this.clearSelection();
    });
  }
}
