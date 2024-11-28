import { Injectable } from '@angular/core';
import { HttpClient } from '@angular/common/http';
import { Observable } from 'rxjs';

@Injectable({
  providedIn: 'root',
})
export class WbsService {
  private apiUrl = 'http://miky2184.ddns.net:4000/wbs';

  constructor(private http: HttpClient) {}

  getWbs(): Observable<any[]> {
    return this.http.get<any[]>(this.apiUrl);
  }

  createWbs(wbs: any): Observable<any> {
    return this.http.post<any>(this.apiUrl, wbs);
  }

  updateWbs(id: string, wbs: any): Observable<any> {
    return this.http.put<any>(`${this.apiUrl}/${id}`, wbs);
  }

  deleteWbs(id: string): Observable<any> {
    return this.http.delete<any>(`${this.apiUrl}/${id}`);
  }
}
