var React = require('react');
var RecipeItemsForm = require('./recipe-items-form');
var RecipeItemStore = require('../stores/recipe-item-store');
var RecipeStore = require('backbone').Model;

module.exports = React.createClass({
  getInitialState: function() {
    var items = new RecipeItemStore(this.props.recipeItems);
    this.addBlankForm(items);
    items.onChange(() => { this.setState({items}); });

    var recipe = new RecipeStore(this.props);
    recipe.on('change', () => { this.setState({recipe}); });
    return { items, recipe };
  },

  addBlankForm: function(items) {
    if (!items.length()) {
      return items.add();
    }
    if (items.getLast().id) {
      items.add();
    }
  },

  willReceiveProps: function(nextProps) {
    this.state.items.updateAll(nextProps.recipeItems);
    this.addBlankForm(this.state.items);
    this.state.recipe.set(nextProps);
  },

  updateField: function(event) {
    var updatedField = {};
    updatedField[event.target.dataset.field] = event.target.value;
    this.state.recipe.set(updatedField);
  },

  errorFor: function(field) {
    if (!this.props.errors[field]) { return; }
    return (<small className="error">{this.props.errors[field]}</small>);
  },

  errorClassFor: function(field) {
    if (!this.props.errors[field]) { return; }
    return 'error';
  },

  showLeadDays: function() {
    var { recipeType, leadDays } = this.state.recipe.toJSON();
    if (recipeType !== 'dough') { return; }
    return (
      <div className="row">
        <div className="small-4 columns end">
          <label className="string required" htmlFor="recipe_lead_days">
            <abbr title="required">*</abbr> Lead Days
          </label>
          <input
            data-field="leadDays"
            className={`${this.errorClassFor('lead_days')}`}
            name='recipe[lead_days]'
            onChange={this.updateField}
            type="text"
            value={leadDays} />
          {this.errorFor('lead_days')}
        </div>
      </div>
    );
  },

  mixUnitsOptions: function() {
    var { mixUnits } = this.state.recipe.toJSON();
    return mixUnits.map((mixUnit) => {
      return <option key={mixUnit[0]} value={mixUnit[0]}>{mixUnit[0]}</option>;
    });
  },

  recipeTypeOptions: function() {
    var { recipeTypes } = this.state.recipe.toJSON();
    return recipeTypes.map((recipeType) => {
      return <option key={recipeType[0]} value={recipeType[0]}>{recipeType[0]}</option>;
    });
  },

  render: function() {
    var {
      name,
      mixSize,
      mixSizeUnit,
      note,
      recipeType
    } = this.state.recipe.toJSON();

    return (<div>
      <fieldset>
        <legend>Recipe Information</legend>
        <div className="row">
          <div className="small-12 columns">
            <label className="string required" htmlFor="recipe_name"><abbr title="required">*</abbr> Name</label>
            <input
              data-field='name'
              className={` ${this.errorClassFor('name')}`}
              name='recipe[name]'
              onChange={this.updateField}
              type="text"
              value={name} />
            {this.errorFor('name')}
          </div>
        </div>
        <div className="row">
          <div className="small-12 columns">
            <label htmlFor="recipe_note">Note</label>
            <div className="input text optional recipe_note">
              <textarea
              data-field='note'
              className="text optional"
              name="recipe[note]"
              onChange={this.updateField}
              value={note} ></textarea>
            {this.errorFor('note')}
            </div>
          </div>
        </div>
        <div className="row">
          <div className="small-4 columns">
            <div className="input select required recipe_recipe_type">
              <label className="recipe_recipe_type select required" htmlFor="recipe_recipe_type">
                <abbr title="required">*</abbr> Recipe type
              </label>
              <select
                data-field="recipeType"
                value={recipeType}
                onChange={this.updateField}
                className={`${this.errorClassFor('recipeType')}`}
                name="recipe[recipe_type]"
              >
                {this.recipeTypeOptions()}
              </select>
            </div>
          </div>
          <div className="small-4 columns">
            <label htmlFor="recipe_mix_size">Mix Size</label>
            <input
              data-field="mixSize"
              className={`bakers_percentage_input ${this.errorClassFor('bakers_percentage')}`}
              name='recipe[mix_size]'
              onChange={this.updateField}
              type="text"
              value={mixSize} />
            {this.errorFor('mixSize')}
            <p className="help-text">
              * Pre-ferment mix bowls will match motherdough bowls when only included in one motherdough
            </p>
          </div>
          <div className="small-4 columns">
            <div className="input select required recipe_recipe_type">
              <label className="select" htmlFor="recipe_recipe_type">Mix Units</label>
              <select
                data-field="mixSizeUnit"
                value={mixSizeUnit}
                onChange={this.updateField}
                className={`${this.errorClassFor('mixSizeUnit')}`}
                name="recipe[mix_size_unit]"
              >
                {this.mixUnitsOptions()}
              </select>
            </div>
          </div>
        </div>
        {this.showLeadDays()}
      </fieldset>
      <RecipeItemsForm recipe={this.state.recipe} recipeItems={this.state.items} />
    </div>);
  }
});
