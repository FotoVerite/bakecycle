import React, { PropTypes } from 'react';
import { Model as RecipeStore } from 'backbone';

import { BCInput, BCTextarea, BCSelect } from './bakecycle-backbone-inputs';
import RecipeItemsForm from './recipe-items-form';
import RecipeItemStore from '../stores/recipe-item-store';

const RecipeForm = React.createClass({
  propTypes: {
    errors: PropTypes.object.isRequired,
    recipeItems: PropTypes.array.isRequired
  },

  getInitialState() {
    var recipe = new RecipeStore(this.props);
    var items = new RecipeItemStore(this.props.recipeItems);
    items.addBlankForm();
    items.on('change sort remove add', () => this.setState({items}));
    recipe.on('change', () => this.setState({recipe}));
    return { items, recipe };
  },

  willReceiveProps(nextProps) {
    this.state.items.set(nextProps.recipeItems);
    this.state.items.addBlankForm();
    this.state.recipe.set(nextProps);
  },

  updateField(event) {
    var updatedField = {};
    updatedField[event.target.dataset.field] = event.target.value;
    this.state.recipe.set(updatedField);
  },

  errorFor(field) {
    if (!this.props.errors[field]) { return; }
    return (<small className="error">{this.props.errors[field]}</small>);
  },

  errorClassFor(field) {
    if (!this.props.errors[field]) { return; }
    return 'error';
  },

  showLeadDays() {
    var recipe = this.state.recipe;
    var { recipeType } = recipe.toJSON();
    if (recipeType !== 'dough') { return; }
    return (
      <div className="row">
        <div className="small-4 columns end">
          <BCInput
            model={recipe}
            field="leadDays"
            name="recipe[lead_days]"
            label="Lead Days"
            required
            error={this.props.errors.lead_days} />
        </div>
      </div>
    );
  },

  mixUnitsOptions() {
    var { mixUnits } = this.state.recipe.toJSON();
    return mixUnits.map((mixUnit) => {
      return <option key={mixUnit[0]} value={mixUnit[0]}>{mixUnit[0]}</option>;
    });
  },

  recipeTypeOptions() {
    var { recipeTypes } = this.state.recipe.toJSON();
    return recipeTypes.map((recipeType) => {
      return <option key={recipeType[0]} value={recipeType[0]}>{recipeType[0]}</option>;
    });
  },

  render() {
    var recipe = this.state.recipe;
    return (<div>
      <fieldset>
        <legend>Recipe Information</legend>
        <div className="row">
          <div className="small-12 columns">
            <BCInput
              model={recipe}
              field="name"
              name="recipe[name]"
              label="Name"
              required
              error={this.props.errors.name}
            />
          </div>
        </div>
        <div className="row">
          <div className="small-12 columns">
            <BCTextarea
              model={recipe}
              field="note"
              name="recipe[note]"
              label="Note"
              error={this.props.errors.note}
            />
          </div>
        </div>
        <div className="row">
          <div className="small-4 columns">
            <BCSelect
              model={recipe}
              field="recipeType"
              options={this.recipeTypeOptions()}
              name="recipe[recipe_type]"
              label="Recipe type"
              required
              error={this.props.errors.recipe_type} />
          </div>
          <div className="small-4 columns">
            <BCInput
              model={recipe}
              field="mixSize"
              name="recipe[mix_size]"
              label="Mix Size"
              type="number"
              error={this.props.errors.mix_size} />
            <p className="help-text">
              * Pre-ferment mix bowls will match motherdough bowls when only included in one motherdough
            </p>
          </div>
          <div className="small-4 columns">
            <BCSelect
              model={recipe}
              field="mixSizeUnit"
              options={this.mixUnitsOptions()}
              name="recipe[mix_size_unit]"
              label="Mix Units"
              error={this.props.errors.mix_size_unit} />
          </div>
        </div>
        {this.showLeadDays()}
      </fieldset>
      <RecipeItemsForm recipe={this.state.recipe} recipeItems={this.state.items} />
    </div>);
  }
});

export default RecipeForm;
