import React from 'react';
import { render, screen, fireEvent } from '@testing-library/react';
import ProductPriceForm from 'components/product-price-form';

const clients = [{ id: 1, name: 'Acme' }];

describe('ProductPriceForm — item management', () => {
  it('renders with one blank row when product has no price variants', () => {
    const { container } = render(
      <ProductPriceForm product={{ priceVariants: [] }} clients={clients} />
    );
    expect(container.querySelectorAll('.fields').length).toBe(1);
  });

  it('adds a blank row when product has existing persisted variants', () => {
    const { container } = render(
      <ProductPriceForm
        product={{ priceVariants: [{ id: 5, clientId: 1, quantity: 10, price: '2.00' }] }}
        clients={clients}
      />
    );
    expect(container.querySelectorAll('.fields').length).toBe(2);
  });

  it('does not add blank row when last existing variant is unsaved', () => {
    const { container } = render(
      <ProductPriceForm
        product={{ priceVariants: [{ clientId: 1 }] }}
        clients={clients}
      />
    );
    expect(container.querySelectorAll('.fields').length).toBe(1);
  });

  it('adds a new row when clicking Add New Price', () => {
    const { container, getByText } = render(
      <ProductPriceForm product={{ priceVariants: [] }} clients={clients} />
    );
    fireEvent.click(getByText('Add New Price'));
    expect(container.querySelectorAll('.fields').length).toBe(2);
  });

  it('removes unsaved rows when X is clicked', () => {
    const { container, getAllByText } = render(
      <ProductPriceForm product={{ priceVariants: [] }} clients={clients} />
    );
    fireEvent.click(getAllByText('X')[0]);
    expect(container.querySelectorAll('.fields').length).toBe(0);
  });

  it('marks saved rows as destroyed (does not remove them)', () => {
    const { container, getAllByText } = render(
      <ProductPriceForm
        product={{ priceVariants: [{ id: 5, clientId: 1, quantity: 10, price: '2.00' }] }}
        clients={clients}
      />
    );
    // click X on the first (persisted) row
    fireEvent.click(getAllByText('X')[0]);
    // row still exists with disabled class
    expect(container.querySelectorAll('.fields.disabled').length).toBe(1);
    // hidden destroy field is present
    expect(container.querySelector('input[name*="_destroy"]')).toBeTruthy();
  });

  it('assigns unique numeric keys to each row for Rails nested attributes', () => {
    const { container } = render(
      <ProductPriceForm
        product={{ priceVariants: [{ id: 1 }, { id: 2 }] }}
        clients={clients}
      />
    );
    // Extract the bracket key from the first named input in each row
    const rowKeys = [...container.querySelectorAll('.fields')].map(row => {
      const input = row.querySelector('input[name]');
      return input && input.name.match(/\[(\d+)\]/)[1];
    });
    expect(rowKeys.length).toBe(3); // 2 persisted + 1 blank
    expect(new Set(rowKeys).size).toBe(3); // all distinct
  });
});
