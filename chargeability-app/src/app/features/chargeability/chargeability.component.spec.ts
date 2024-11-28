import { ComponentFixture, TestBed } from '@angular/core/testing';

import { ChargeabilityComponent } from './chargeability.component';

describe('ChargeabilityComponent', () => {
  let component: ChargeabilityComponent;
  let fixture: ComponentFixture<ChargeabilityComponent>;

  beforeEach(async () => {
    await TestBed.configureTestingModule({
      imports: [ChargeabilityComponent]
    })
    .compileComponents();

    fixture = TestBed.createComponent(ChargeabilityComponent);
    component = fixture.componentInstance;
    fixture.detectChanges();
  });

  it('should create', () => {
    expect(component).toBeTruthy();
  });
});
