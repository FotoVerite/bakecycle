import React from 'react';
import PropTypes from 'prop-types';
import {
  BCInput,
  BCSelect
} from '../bakecycle-inputs';

export default function PricingItemFields({
  model,
  onChange,
  weightUnitOptions,
}) {


  return (
    <div className={'row ingredient ' + model.hidden} key={model.id}>
      <div className="small-12 columns">
        <span className="costing-ingredient-name">
          <h3>{model.name}</h3>
        </span>
        <input type="hidden" value={model.dirty} name={`bakery[ingredients_attributes][${model.id}][dirty]`} />
        <input type="hidden" value={model.id} name={`bakery[ingredients_attributes][${model.id}][id]`} />
        <input type="hidden" value={model.cost_over_time_vendor_id} name={`bakery[ingredients_attributes][${model.id}][cost_over_time_vendor_id]`} />
        <input type="hidden" value={new Date().toUTCString()} name={`bakery[ingredients_attributes][${model.id}][updated_at]`} />

        <div className="ingredient-cost-input" key={`${model.id}-cost`}>
          <BCInput
            value={model.cost}
            field="cost"
            name={`bakery[ingredients_attributes][${model.id}][cost]`}
            label="Cost Per Unit"
            labelClass="hide-for-large-up"
            autoComplete="off"
            type="number"
            step="0.01"
            onChange={onChange}
          />
        </div>
        <div className="ingredient-current-amount-grams" key={`${model.id}-current_amount_grams`}>
          <BCSelect
            value={model.weight_unit}
            field="weight_unit"
            name={`bakery[ingredients_attributes][${model.id}][weight_unit]`}
            options={weightUnitOptions}
            label="Amount in"
            onChange={onChange}
          />
        </div>
        <div className="ingredient-conversion" key={`${model.id}-conversion`}>
          <BCInput
            value={model.conversion}
            field="conversion"
            type="number"
            step="0.01"
            name={`bakery[ingredients_attributes][${model.id}][conversion]`}
            labelClass="hide-for-large-up"
            label="Conversion"
            autoComplete="off"
            onChange={onChange}
          />
        </div>
        <div className="ingredient-current-cost-per-gram " key={`${model.id}-current_cost_per_gram`}>
          <label className="hide-for-large-up">Current Cost Per Gram</label>
          <input disabled="true" type="text" value={ (model.cost / model.conversion) } />
        </div>
      </div>
    </div>);
}

PricingItemFields.propTypes = {
  model: PropTypes.object,
  key: PropTypes.string,
  onChange: PropTypes.func,
  weightUnitOptions: PropTypes.array
};
