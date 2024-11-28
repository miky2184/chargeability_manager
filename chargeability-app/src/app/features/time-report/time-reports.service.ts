import { Injectable } from '@angular/core';
import { HttpClient } from '@angular/common/http';
import { Observable } from 'rxjs';

@Injectable({
  providedIn: 'root',
})
export class TimeReportsService {
  private apiUrl = 'http://miky2184.ddns.net:3001/time-reports';

  constructor(private http: HttpClient) {}

  getTimeReports(): Observable<any[]> {
    return this.http.get<any[]>(this.apiUrl);
  }
}
