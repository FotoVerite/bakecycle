import React from 'react';
import PropTypes from 'prop-types';
import { connect } from 'react-redux';
import * as ingredientActions from '../../actions/ingredients';
import CostingItemFields from './costing-item-fields';
import filter from 'lodash.filter';
import includes from 'lodash.includes';
import pluck from 'lodash.pluck';
import uniq from 'lodash.uniq';
import sortby from 'lodash.sortby';
import { BCSearchableSelect } from '../bakecycle-inputs';

class CostingForm extends React.Component {
  fields() {
    var ingredientsSortedByType = {};
    uniq(pluck(this.props.ingredients, 'ingredient_type')).sort().map(type => {
      var filtered = filter(this.props.ingredients, ['ingredient_type', type]).map(ingredient => {
        ingredient.hidden = (this.props.filter.length > 0 && !includes(this.props.filter, parseInt(ingredient.id))) ? 'hide' : '';
        return ingredient;
      });
      ingredientsSortedByType[type] = sortby(filtered, 'name');
    });

    var vendorOptions = this.props.availableVendors.map(vendor => (
      <option key={`vendor-${vendor.id}`} value={vendor.id}>{vendor.name}</option>
    ));
    var weightUnitOptions = this.props.weightUnitOptions.map(option => (
      <option key={`weight-unit-${option}`} value={option}>{option}</option>
    ));

    var self = this;
    return Object.keys(ingredientsSortedByType).map(function(key) {
      return (
        <div key={key}>
          <hr />
          <h2>{key}</h2>
          {ingredientsSortedByType[key].map(model =>
            <CostingItemFields
              vendorOptions={vendorOptions}
              key={`${key}-${model.id}`}
              model={model}
              onChange={self.props.updateIngredient.bind(null, model)}
              weightUnitOptions={weightUnitOptions}
            />)}
        </div>
      );
    });
  }

  render() {
    return (
      <fieldset>
        <legend>Costing</legend>
        <div className="filter">
          <BCSearchableSelect
            value={this.props.filter}
            field="filter"
            name="filter"
            options={this.props.ingredients.map(ingredient => ({ value: ingredient.id, label: ingredient.name }))}
            label="Filter"
            labelClass="hide-for-large-up"
            includeBlank="Filter Ingredients"
            multi={true}
            onChange={this.props.filterIngredients}
          />
          <br />
          <input type="submit" value="Update Costing" className="button btn" />
        </div>
        <div className="row show-for-large-up">
          <div className="small-12 columns">
            <div className="costing-ingredient-name"><label>Ingredient</label></div>
            <div className="ingredient-vendor-selection"><label>Vendor</label></div>
            <div className="ingredient-cost-input"><label>Cost Per Unit</label></div>
            <div className="ingredient-current-amount-grams"><label>Conversion To Grams</label></div>
            <div className="ingredient-weight-units"><label>Bought By Units</label></div>
            <div className="ingredient-conversion"><label>Conversion</label></div>
            <div className="ingredient-current-cost-per-gram"><label>Cost/Gram</label></div>
          </div>
        </div>
        {this.fields()}
        <input type="submit" value="Update Costing" className="button btn" />
      </fieldset>
    );
  }
}

CostingForm.propTypes = {
  ingredients: PropTypes.array,
  availableVendors: PropTypes.array,
  updateIngredient: PropTypes.func,
  filterIngredients: PropTypes.func,
  filter: PropTypes.array,
  weightUnitOptions: PropTypes.array,
};

const stateToProps = function(state) {
  return {
    ingredients: state.ingredients,
    availableVendors: state.availableVendors,
    filter: state.filter,
    weightUnitOptions: state.weightUnitOptions,
  };
};

export default connect(stateToProps, ingredientActions)(CostingForm);
