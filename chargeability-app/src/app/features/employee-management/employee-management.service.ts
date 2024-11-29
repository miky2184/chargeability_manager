import { Injectable } from '@angular/core';
import { HttpClient } from '@angular/common/http';
import { Observable } from 'rxjs';

@Injectable({
  providedIn: 'root',
})
export class ResourceService {
  private apiUrl = 'https://miky2184.ddns.net:4000/resources';

  constructor(private http: HttpClient) {}

  getResource(): Observable<any[]> {
    return this.http.get<any[]>(this.apiUrl);
  }

  createResource(resource: any): Observable<any> {
    return this.http.post<any>(this.apiUrl, resource);
  }

  updateResource(id: string, resource: any): Observable<any> {
    return this.http.put<any>(`${this.apiUrl}/${id}`, resource);
  }

  deleteResource(id: string): Observable<any> {
    return this.http.delete<any>(`${this.apiUrl}/${id}`);
  }
}
