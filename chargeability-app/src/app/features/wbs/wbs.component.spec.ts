import { ComponentFixture, TestBed } from '@angular/core/testing';

import { WbsComponent } from './wbs.component';

describe('WbsComponent', () => {
  let component: WbsComponent;
  let fixture: ComponentFixture<WbsComponent>;

  beforeEach(async () => {
    await TestBed.configureTestingModule({
      imports: [WbsComponent]
    })
    .compileComponents();

    fixture = TestBed.createComponent(WbsComponent);
    component = fixture.componentInstance;
    fixture.detectChanges();
  });

  it('should create', () => {
    expect(component).toBeTruthy();
  });
});
