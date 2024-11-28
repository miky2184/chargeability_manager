import { Injectable } from '@angular/core';
import { HttpClient } from '@angular/common/http';
import { Observable } from 'rxjs';

@Injectable({
  providedIn: 'root',
})
export class ChargeabilityService {
  private apiUrl = 'http://miky2184.ddns.net:4000/chargeability';

  constructor(private http: HttpClient) {}

  getChargeability(): Observable<any[]> {
    return this.http.get<any[]>(this.apiUrl);
  }
}
