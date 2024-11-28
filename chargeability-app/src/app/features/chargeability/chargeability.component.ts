import { Component, OnInit } from '@angular/core';
import { CommonModule } from '@angular/common';
import { ChargeabilityService } from './chargeability.service';

@Component({
  selector: 'app-chargeability',
  standalone: true,
  imports: [CommonModule],
  templateUrl: './chargeability.component.html',
  styleUrl: './chargeability.component.css'
})
export class ChargeabilityComponent implements OnInit {
  chargeability: any[] = []
  isLoading = true;

  constructor(private chargeabilityService: ChargeabilityService) {}

  ngOnInit(): void {
    this.chargeabilityService.getChargeability().subscribe(
      (data) => {
        console.log('Dati ricevuti:', data); // Log dei dati per debug
        this.chargeability = data;
        this.isLoading = false;
      },
      (error) => {
        console.error('Errore durante il caricamento dei dati:', error);
        this.isLoading = false;
      }
    );
  }

}
