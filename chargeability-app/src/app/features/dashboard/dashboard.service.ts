import { Injectable } from '@angular/core';
import { HttpClient } from '@angular/common/http';
import { Observable } from 'rxjs';

@Injectable({
  providedIn: 'root',
})
export class DashboardService {
  private apiUrl = 'https://miky2184.ddns.net:4000/forecast';

  constructor(private http: HttpClient) {}

  getForecast(): Observable<any[]> {
    return this.http.get<any[]>(this.apiUrl);
  }
}
