import { Component, OnInit } from '@angular/core';
import { CommonModule } from '@angular/common';
import { ChargeabilityService } from './chargeability.service';
import { NgxDatatableModule } from '@swimlane/ngx-datatable';

@Component({
  selector: 'app-chargeability',
  standalone: true,
  imports: [CommonModule, NgxDatatableModule],
  templateUrl: './chargeability.component.html',
  styleUrl: './chargeability.component.css'
})
export class ChargeabilityComponent implements OnInit {
  chargeabilityData: any[] = []
  isLoading = true;

  constructor(private chargeabilityService: ChargeabilityService) {}

  ngOnInit(): void {
    this.chargeabilityService.getChargeability().subscribe(
      (data) => {
        console.log('Dati ricevuti:', data); // Log dei dati per debug
        this.chargeabilityData = data;
        this.isLoading = false;
      },
      (error) => {
        console.error('Errore durante il caricamento dei dati:', error);
        this.isLoading = false;
      }
    );
  }

}
