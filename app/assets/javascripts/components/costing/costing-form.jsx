import React from 'react';
import PropTypes from 'prop-types';
import createReactClass from 'create-react-class';
import { connect } from 'react-redux';
import * as ingredientActions from '../../actions/ingredients';
import filter from 'lodash.filter';
import includes from 'lodash.includes';
import pluck from 'lodash.pluck';
import uniq from 'lodash.uniq';
import sortby from 'lodash.sortby';

import {
  BCInput,
  BCSelect,
  BCSearchableSelect
} from '../bakecycle-inputs';

const CostingForm = createReactClass({
  propTypes: {
    ingredients: PropTypes.array.isRequired,
    availableVendors: PropTypes.array,
    updateIngredient: PropTypes.func.isRequired,
    filterIngredients: PropTypes.func.isRequired,
    filter: PropTypes.array.isRequired
  },

  errorFor(field) {
    const { errors } = this.props.ingredients;
    return errors[field] && errors[field][0];
  },



  fields() {

    var ingredientsSortedByType = {};
    uniq(pluck(this.props.ingredients, 'ingredient_type')).sort().map(type => {
      var filtered =  filter(this.props.ingredients, ['ingredient_type', type]).map(ingredient => {
        if(this.props.filter.length > 0 && !(includes(this.props.filter, parseInt(ingredient.id)))) {
          ingredient.hidden = 'hide';
        }
        else {
          ingredient.hidden = '';
        }
        return ingredient;
      });
      ingredientsSortedByType[type] = sortby(filtered, 'name');
    });

    var vendorOptions = this.props.availableVendors.map(vendor => (
      <option key={`vendor-${vendor.id}`} value={vendor.id}>{vendor.name}</option>
    ));

    var self = this;
    return Object.keys(ingredientsSortedByType).map(function(key){
      return (
        <div key={key}>
          <hr />
          <h2>{key}</h2>
          {self.ingredientFields(ingredientsSortedByType[key], vendorOptions)}
        </div>
      );
    });

  },

  ingredientFields(ingredients, vendorOptions) {
    var self = this;
    return ingredients.map(model => {

      var lb; 
      if(model.current_amount == 0.0){
        lb = 0.0;
      }
      else {
        lb = Math.round(model.current_amount / 453.5);
      }
      return (<div className={'row ingredient ' + model.hidden} key={model.id}>
        <div className="small-12 columns">
          <span className="costing-ingredient-name">
            {model.name}
          </span>
          <input type="hidden" value={model.dirty} name={`bakery[ingredients_attributes][${model.id}][dirty]`} />
          <input type="hidden" value={model.id} name={`bakery[ingredients_attributes][${model.id}][id]`} />
          <div className="ingredient-vendor-selection">
            <BCSelect
              value={model.vendor_id}
              field="vendor_id"
              name={`bakery[ingredients_attributes][${model.id}][vendor_id]`}
              options={vendorOptions}
              label="Vendor"
              labelClass="hide-for-large-up"
              includeBlank="--None--"
              onChange={self.props.updateIngredient.bind(null, model)}
            />
          </div>
          <div className="ingredient-cost-input" key={`${model.id}-cost`}>
            <BCInput
              value={model.cost}
              field="cost"
              name={`bakery[ingredients_attributes][${model.id}][cost]`}
              label="cost"
              labelClass="hide-for-large-up"
              autoComplete="off"
              onChange={self.props.updateIngredient.bind(null, model)}
            />
          </div>
          <div className="ingredient-current-amount-lb" key={`${model.id}-current_amount_lb`}>
            <label className="ide-for-large-up">Amount in LB</label>
            <input disabled="true" type="text" value={lb} />
          </div>
          <div className="ingredient-current-amount-grams" key={`${model.id}-current_amount_grams`}>
            <BCInput
              value={model.current_amount}
              field="current_amount"
              name={`bakery[ingredients_attributes][${model.id}][current_amount]`}
              label="Amount in Grams"
              labelClass="hide-for-large-up"
              autoComplete="off"
              onChange={self.props.updateIngredient.bind(null, model)}
            />
          </div>
          <div className="ingredient-current-cost-per-gram " key={`${model.id}-current_cost_per_gram`}>
            <label className="hide-for-large-up">Current Cost Per Gram</label>
            <input disabled="true" type="text" value={ (model.cost / 1000) } />
          </div>
        </div>
      </div>);
    });
  },

  render() {
    return( 
      <fieldset>
        <legend>Costing</legend>
        <div className="filter">
          <BCSearchableSelect
            value={this.props.filter}
            field="filter"
            name="filter"
            options={this.props.ingredients.map(ingredient => (
              {  value: ingredient.id,
                label: ingredient.name
              }
            ))}
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
            <div className="costing-ingredient-name">
              <label>Ingredient</label>
            </div>
            <div className="ingredient-vendor-selection">
              <label>Vendor</label>
            </div>
            <div className="ingredient-cost-input">
              <label>Cost Per KG</label>
            </div>
            <div className="ingredient-current-amount-lb">
              <label>LB</label>
            </div>
            <div className="ingredient-current-amount-grams">
              <label>Grams</label>
            </div>
            <div className="ingredient-current-cost-per-gram">
              <label>Cost/Gram</label>
            </div>
          </div>
        </div>
        {this.fields()}
        <input type="submit" value="Update Costing" className="button btn" />
      </fieldset>
    );
  }
});


const stateToProps = function(state) {
  return { 
    ingredients: state.ingredients,
    availableVendors: state.availableVendors ,
    filter: state.filter
  };
};

export default connect(stateToProps, ingredientActions)(CostingForm);
